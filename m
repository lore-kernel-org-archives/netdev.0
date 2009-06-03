From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] netdev: Added KS8842 driver
Date: Wed, 3 Jun 2009 10:38:46 +0200
Message-ID: <200906031038.47050.florian@openwrt.org>
References: <4A25745E.3050402@mocean-labs.com> <20090602191122.GA5800@psychotron.englab.brq.redhat.com> <4A25831A.7010003@mocean-labs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org
To: Richard =?iso-8859-1?q?R=3F=F6jfors?=
	<richard.rojfors.ext@mocean-labs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f168.google.com ([209.85.220.168]:61365 "EHLO
	mail-fx0-f168.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553AbZFCIiu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 04:38:50 -0400
Received: by fxm12 with SMTP id 12so7207194fxm.37
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2009 01:38:51 -0700 (PDT)
In-Reply-To: <4A25831A.7010003@mocean-labs.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Tuesday 02 June 2009 21:52:58 Richard R?=F6jfors, vous avez =E9crit=A0=
:
> Jiri Pirko wrote:
> >> +config KS8842
> >> +	tristate "Micrel KSZ8842"
> >> +	depends on PCI
> >
> > Why does this driver depend on PCI ?
>
> Good question.
> The KS8842 switch is actually behind an FPGA connected via PCIe,
> the next version of the FPGA firmware will have DMA support and the d=
river
> will depend on PCI. Is it worth removing the dependency for now?

You are not using any pci_* functions so I guess you can remove that=20
dependency for now.
--=20
Best regards, Florian Fainelli
Email : florian@openwrt.org
http://openwrt.org
-------------------------------
