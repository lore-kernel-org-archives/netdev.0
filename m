From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 1/1] Drivers: net-next: hyperv: Fix a bug in
 netvsc_start_xmit()
Date: Mon, 29 Sep 2014 03:51:32 +0000
Message-ID: <90e56f4692144d77b9d1cee3a2cea667@BY2PR0301MB0711.namprd03.prod.outlook.com>
References: <1411958991-28049-1-git-send-email-kys@microsoft.com>
 <20140928.231647.1355757349883305047.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "stable@vger.kernel.org" <stable@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140928.231647.1355757349883305047.davem@davemloft.net>
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



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Sunday, September 28, 2014 8:17 PM
> To: KY Srinivasan
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> jasowang@redhat.com; stable@vger.kernel.org
> Subject: Re: [PATCH 1/1] Drivers: net-next: hyperv: Fix a bug in
> netvsc_start_xmit()
> 
> From: "K. Y. Srinivasan" <kys@microsoft.com>
> Date: Sun, 28 Sep 2014 19:49:51 -0700
> 
> > After the packet is successfully sent, we should not touch the skb as
> > it may have been freed. This patch is based on the work done by Long
> > Li <longli@microsoft.com>.
> >
> > Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> > Tested-by: Long Li <longli@microsoft.com>
> > Cc: <stable@vger.kernel.org>
> 
> You hyperv guys really have to get your act together.  This is not properly
> submitted.
> 
> Most importantly, this is a serious reference to free memory bug.
> Therefore it should be targetted at 'net' not 'net-next'.
> 
> Secondly, you do not CC: stable for networking changes, you instead ask me
> to queue it up for my next batch of -stable networking changes.
> 
> Thirdly, your Subject line is malformed.  You should not use
> "Drivers: " as a prefix.  Just the driver name is sufficient.
> You should also not mentionen the target GIT tree outside of the [PATCH ...]
> bracketed area.
> 
> Also, please be cognizant of how much of my time you unnecessarily
> consume when you make a malformed submission like this.  That is time I
> could spend reviewing other patches.

Sorry about that; I will resubmit this patch after addressing all the issues you have raised.

Regards,

K. Y
