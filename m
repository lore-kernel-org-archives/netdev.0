From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next,1/1] hyperv: Move wait completion msg code into
 rndis_filter_halt_device()
Date: Sun, 5 Aug 2012 19:16:32 +0000
Message-ID: <A1F3067C9B68744AA19F6802BAB8FFDC0DDFAEF4@TK5EX14MBXC223.redmond.corp.microsoft.com>
References: <1344022338-3010-1-git-send-email-haiyangz@microsoft.com>
 <20120803.165212.106382119661240198.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <20120803.165212.106382119661240198.davem@davemloft.net>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Friday, August 03, 2012 7:52 PM
> To: Haiyang Zhang
> Cc: netdev@vger.kernel.org; KY Srinivasan; olaf@aepfle.de;
> jasowang@redhat.com; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org
> Subject: Re: [PATCH net-next,1/1] hyperv: Move wait completion msg code
> into rndis_filter_halt_device()
> 
> From: Haiyang Zhang <haiyangz@microsoft.com>
> Date: Fri,  3 Aug 2012 12:32:18 -0700
> 
> > We need to wait for send_completion msg before put_rndis_request() at
> > the end of rndis_filter_halt_device(). Otherwise,
> > netvsc_send_completion() may reference freed memory which is
> overwritten, and cause panic.
> >
> > Reported-by: Long Li <longli@microsoft.com>
> > Reported-by: Jason Wang <jasowang@redhat.com>
> > Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> 
> This is a bug fix, so applied to 'net'.  Please target your patches properly.
> 
> Don't just be afraid that I'll reject the patch if you target it at 'net', and
> therefore just target everything at 'net-next'.  That is certainly worse.

I see. 

Thanks,
- Haiyang
