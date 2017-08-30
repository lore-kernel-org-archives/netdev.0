From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] staging: r8822be: Fix typo for CONFIG_RTLWIFI_DEBUG
Date: Wed, 30 Aug 2017 11:28:11 -0500
Message-ID: <bd847ff7-8777-a89f-807c-df726d7561f7@lwfinger.net>
References: <20170829112643.GA14571@kroah.com>
 <1504006208-18965-1-git-send-email-andreas.ziegler@fau.de>
 <fcab4e04-be42-5a05-c5ad-4947d2d41164@lwfinger.net>
 <20170829144216.GA22295@kroah.com>
 <bd895fab-dfb1-aa80-1ce5-4cad55d0e234@fau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev <netdev@vger.kernel.org>,
 Yan-Hsuan Chuang <yhchuang@realtek.com>, Steven Ting <steventing@realtek.com>,
 Birming Chiu <birming@realtek.com>
To: Andreas Ziegler <andreas.ziegler@fau.de>,
 Greg KH <gregkh@linuxfoundation.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <bd895fab-dfb1-aa80-1ce5-4cad55d0e234@fau.de>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On 08/30/2017 02:58 AM, Andreas Ziegler wrote:
> Indeed, sorry I missed that as well.
> 
> So what should we make of that #ifdef? The code inside it doesn't compile
> (anymore? I didn't find any development history for that patch except the
> original mail), as there is no definition of struct submit_ctx in the headers
> (for other rtl drivers - 8188eu, 8723bs - that struct lives in
> include/rtw_xmit.h). Is a comparable header simply missing?
> 
> Regards,
> 
> Andreas

Andreas,

I'm sorry that I did not have time yesterday to properly analyze the situation. 
All I knew is that your patch was not the correct one. It turns out that the 
extra code was left over from the original writing/testing of the driver and 
should have been deleted. I have prepared a patch that does that and will submit 
it soon.

When the extraneous code was deleted, addition simplifications of the code were 
apparent. I am currently testing that change, and will submit the two patches at 
the same time.

Larry
