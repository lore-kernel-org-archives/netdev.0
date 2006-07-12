From: Andreas Kleen <ak@suse.de>
Subject: Re: skge error; hangs w/ hardware memory hole
Date: Wed, 12 Jul 2006 04:54:54 +0200 (CEST)
Message-ID: <121226.1152672894714.SLOX.WebMail.wwwrun@imap-dhs.suse.de>
References: <20060703205238.GA10851@deprecation.cyrius.com> <20060707141843.73fc6188@dxpl.pdx.osdl.net> <200607072328.51282.ak@suse.de> <44B46276.5030006@suespammers.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Martin Michlmayr <tbm@cyrius.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kevin@sysexperts.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:37603 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S932129AbWGLCzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2006 22:55:03 -0400
To: Anthony DeRobertis <asd@suespammers.org>
In-Reply-To: <44B46276.5030006@suespammers.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Spamming bug robot dropped from cc list.

Am Mi 12.07.2006 04:46 schrieb Anthony DeRobertis <asd@suespammers.org>:

> OK, here are the results with iommu=force. All of these are copied
> down
> by hand, so please forgive any transcription errors:

You need to use iommu=soft swiotlb=force

The standard IOMMU is also broken on VIA, but forced swiotlb should
work.

However it is a bit slow because it will force all IO through an
additional copy.
If it helps I can do a proper patch that only bounces IO > 4GB through
the copy.

> Honestly, should I chuck this board through the window of my nearest
> ASUS and/or VIA office, and buy an NForce board?

We can probably get it to work, but you're clearly outside validated
territory (= you're running the hardware in a untested by the vendor
configuration). Normally that's not a good idea.

BTW there are NForce systems with similar problems, but they are
rare.

-Andi


