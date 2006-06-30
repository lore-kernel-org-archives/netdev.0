From: Dave Jones <davej@redhat.com>
Subject: Re: 2.6.17-mm4
Date: Fri, 30 Jun 2006 13:27:13 -0400
Message-ID: <20060630172713.GH32729@redhat.com>
References: <20060629013643.4b47e8bd.akpm@osdl.org> <6bffcb0e0606291339s69a16bc5ie108c0b8d4e29ed6@mail.gmail.com> <20060629204330.GC13619@redhat.com> <20060629210950.GA300@elte.hu> <20060629230517.GA18838@elte.hu> <1151662073.31392.4.camel@localhost.localdomain> <1151661242.11434.20.camel@laptopd505.fenrus.org> <1151669670.31392.16.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58554 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S932301AbWF3R1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 13:27:36 -0400
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Content-Disposition: inline
In-Reply-To: <1151669670.31392.16.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 30, 2006 at 01:14:30PM +0100, Alan Cox wrote:
 > Ar Gwe, 2006-06-30 am 11:54 +0200, ysgrifennodd Arjan van de Ven:
 > > another quick hack is to check for vesa lb... eg if pci is present, skip
 > > this thing entirely :)
 > 
 > Not really, many people made VLB/PCI combo boards.

- check the pci version (I'm pretty sure these were pre PCI 2.0 ?)
- check for dmi existance
  DMI came after VLB didn't it?  Even if not, the BIOS date may
  give clues. I don't recall VLB after 1996 or so.
- check for acpi existance.
  surely no-one made an acpi aware vlb machine :)

There are probably other creative ways.

		Dave

-- 
http://www.codemonkey.org.uk
