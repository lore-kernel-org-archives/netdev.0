From: Nils Rennebarth <nils.rennebarth@funkwerk-ec.com>
Subject: Re: quirk_e100_interrupt() called too early
Date: Mon, 2 Jul 2007 10:07:52 +0200
Message-ID: <4688B258.4000501@funkwerk-ec.com>
References: <4683A80F.5020605@semihalf.com> <4683DB44.9070704@intel.com> <200706282007.27841.bjorn.helgaas@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Marian Balakowicz <m8@semihalf.com>,
	"linux-pci@atrey.karlin.mff.cuni.cz"
	<linux-pci@atrey.karlin.mff.cuni.cz>,
	"len.brown@intel.com" <len.brown@intel.com>,
	NetDev <netdev@vger.kernel.org>
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [85.93.77.62] ([85.93.77.62]:53560 "EHLO
	virgo.stuttgart.de.funkwerk-ec.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751457AbXGBIN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2007 04:13:27 -0400
In-Reply-To: <200706282007.27841.bjorn.helgaas@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bjorn Helgaas wrote:
> On Thursday 28 June 2007 10:01:08 am Kok, Auke wrote:
> I copied Nils Rennebarth, who originally reported the bug:
>   http://bugzilla.kernel.org/show_bug.cgi?id=3D5918
> in case he can test your patch.
Most of the embedded boards we now work with appear to exhibit the same=
=20
behaviour: During boot the

=46irmware left 0000:01:05.0 e100 interrupts enabled, disabling

message appears for all four e100 nics. (The mainboard is a em-8510A=20
btw.) When I have time I could try if the quirk still works with the
mentioned patch, but I am quite busy with other things at the moment.

--=20

Mit freundlichen Gr=FC=DFen / with kind regards

Nils Rennebarth, Software Developer

--
=46unkwerk IP-Appliances GmbH
M=F6nchhaldenstra=DFe 28
D-70191 Stuttgart

Tel: +49 711 900300 - 0
=46ax: +49 711 900300 - 90

E-Mail: Nils.Rennebarth@funkwerk-ec.com

Location: GmbH Neu-Ulm, Local Court Memmingen, HRB 13043
Managing Directors: Michael Marsanu, Soenke Weisner

--------------------------------
The information contained in this e-mail has been carefully researched,
but the possibility of it being inapplicable in individual cases cannot
be ruled out. We therefore regret that we cannot accept responsibility
or liability of any kind whatsoever for the correctness of the
information given. Please notify us if you discover that information is
inapplicable.
