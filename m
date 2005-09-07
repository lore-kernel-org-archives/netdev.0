From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [patch 1/1] ipw2100: remove by-hand function entry/exit debugging
Date: Wed, 7 Sep 2005 15:39:08 +0200
Message-ID: <200509071539.08780.netdev@axxeo.de>
References: <200509062056.j86KuHcL031448@shell0.pdx.osdl.net> <20050906.194111.130652562.davem@davemloft.net> <431E5514.2070003@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, akpm@osdl.org,
	pavel@ucw.cz, ipw2100-admin@linux.intel.com, pavel@suse.cz,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751215AbVIGNjT@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <431E5514.2070003@pobox.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

Jeff Garzik wrote:
> David S. Miller wrote:
> > From: Jeff Garzik <jgarzik@pobox.com>
> > Date: Tue, 06 Sep 2005 21:51:21 -0400
> >
> >>NAK.  Rationale: maintainer's choice.  Pavel doesn't get to choose
> >>the debugger of choice for the driver maintainer.
> >
> > If it makes the driver unreadable and thus harder to maintain,
> > I think such changes should seriously be considered.
> >
> > Most of the DEBUG_INFO macro usage is fine, but those "enter"
> > and "exit" ones are just pure noise and should be removed.
>
> I find them useful in my own drivers; they are definitely not pure noise.

gcc -finstrument-functions

can do that completely without adding noise to the sources.

been there, done that. With a gcc-patch you don't even need to 
resolve symbols.


Regards

Ingo Oeser
