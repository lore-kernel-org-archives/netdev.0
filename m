From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: xen-netback regression in 3.10.18
Date: Tue, 12 Nov 2013 09:27:06 +0000
Message-ID: <1384248426.1883.16.camel@kazak.uk.xensource.com>
References: <527B8465.6050901@citrix.com>
	 <20131109.155705.1091114498622318881.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <david.vrabel@citrix.com>, <netdev@vger.kernel.org>,
	<stable@vger.kernel.org>, <paul.durrant@citrix.com>,
	<wei.liu2@citrix.com>
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20131109.155705.1091114498622318881.davem@davemloft.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-11-09 at 15:57 -0500, David Miller wrote:
> From: David Vrabel <david.vrabel@citrix.com>
> Date: Thu, 7 Nov 2013 12:15:33 +0000
> 
> > 3.10.18 included 279f438e36c0 (xen-netback: Don't destroy the netdev
> > until the vif is shut down) but this has a regression that was fixed by
> > dc62ccaccfb1 (xen-netback: transition to CLOSED when removing a VIF)
> > 
> > dc62ccaccfb1 depends on ea732dff5cfa (xen-netback: Handle backend state
> > transitions in a more robust way) which is also a bug fix for certain
> > Windows frontend drivers and is thus also a stable candidate.
> > 
> > Dave can you ensure these two commits are tagged for the next 3.10.y
> > stable release?
> > 
> >   ea732dff5cfa10789007bf4a5b935388a0bb2a8f
> >   dc62ccaccfb139d9b04bbc5a2688a4402adbfab3
> 
> Ian already asked me to do this,

Sorry, bit of a race condition after Dave V and I spoke. Seems like I
won by 3s ;-)

> and the commits are necessary for 3.11 -stable as well.
> 
> They've been queued up.

Thanks.

Ian.
