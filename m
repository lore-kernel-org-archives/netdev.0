From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH net-next 2/4] net: systemport: use the new fixed PHY
 helpers
Date: Tue, 20 May 2014 00:04:20 +0200
Message-ID: <20140520000420.7039e1bc@free-electrons.com>
References: <1400528625-32744-1-git-send-email-f.fainelli@gmail.com>
	<1400528625-32744-3-git-send-email-f.fainelli@gmail.com>
	<20140519221946.27dbad55@free-electrons.com>
	<CAGVrzcYwp6W7YgDmAbe3d+LEX105d+s1j2jV4zvAm52rWTt5rg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:55613 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750763AbaESWE2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 18:04:28 -0400
In-Reply-To: <CAGVrzcYwp6W7YgDmAbe3d+LEX105d+s1j2jV4zvAm52rWTt5rg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Florian Fainelli,

On Mon, 19 May 2014 14:52:57 -0700, Florian Fainelli wrote:

> >> +     /* SYSTEMPORT uses the old 'fixed-link' 5-digit property which is
> >> +      * deprecated, we need to register the fixed PHY using the Ethernet
> >> +      * MAC node since we do not have a 'fixed-link' subnode.
> >> +      */
> >
> > Actually even if you use the new fixed PHY DT binding, the DT node
> > linked to the PHY is the Ethernet MAC node. This is because I didn't
> > want to have a difference between how things are handled between the
> > old and the new binding.
> 
> Sure, I agree, and the comment still stands, I am just expressing it
> that we are not looking for the 'fixed-link' subnode, but the
> 'fixed-link' 5-digit property here. Would you want me to rephrase
> that?

What I found misleading in the comment is that you simply to imply that
because you're not using the new DT binding for fixed-link, the DT node
that is associated to the PHY is the Ethernet MAC.

The truth is that the DT node associated to the fixed PHY is always the
Ethernet MAC, regardless of whether you're using the old or the new DT
binding.

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
