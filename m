From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH 1/5] drivers: net: usb: rtl8150: bug fixing and cleanup
Date: Mon, 20 May 2013 10:49:46 +0300 (EEST)
Message-ID: <alpine.DEB.2.02.1305201049210.3374@fry.nucleusys.com>
References: <alpine.DEB.2.02.1305201008190.4719@fry.nucleusys.com> <20130520.001252.838327096610376306.davem@davemloft.net> <alpine.DEB.2.02.1305201014220.4719@fry.nucleusys.com> <20130520.004324.1700573748194578434.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130520.004324.1700573748194578434.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 May 2013, David Miller wrote:

> From: Petko Manolov <petkan@nucleusys.com>
> Date: Mon, 20 May 2013 10:18:17 +0300 (EEST)
> 
> > On Mon, 20 May 2013, David Miller wrote:
> > 
> >> From: Petko Manolov <petkan@nucleusys.com>
> >> Date: Mon, 20 May 2013 10:09:00 +0300 (EEST)
> >> 
> >> > What about the .c/.h split?
> >> 
> >> I have no strong opinion either way.
> > 
> > OK, so i'll prepare new patch series that coalesce my original patch #1 
> > and #2, and apply the Francois suggestion about using the generic 
> > netdev_alloc_skb_ip_align() in the interrupt path.
> > 
> > Which tree would you want me to diff against?
> 
> As has been explained to you already, cleanups belong in 'net-next',
> bug fixes belong in 'net'.
> 
> If you series has both, you have to submit them separately.  Submit
> the bug fixes to 'net', then the next time I merge 'net' into 'net-next'
> you can submit the cleanups on top against 'net-next'.

Got it.  Thanks.
