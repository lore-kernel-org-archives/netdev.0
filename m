From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH] HTB O(1) class lookup
Date: Mon, 5 Feb 2007 13:45:27 +0100
Message-ID: <200702051345.27827.netdev@axxeo.de>
References: <20070205101637.GB1863@ff.dom.local> <200702051224.53777.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@o2.pl>, Simon Lodal <simonl@parknet.dk>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	lartc@mailman.ds9a.nl
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:40256 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932268AbXBEMpz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 07:45:55 -0500
In-Reply-To: <200702051224.53777.ak@suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen schrieb:
> On Monday 05 February 2007 11:16, Jarek Poplawski wrote:
> > I wonder, why not try, at least for a while, to do this
> > a compile (menuconfig) option with a comment:
> > recommended for a large number of classes. After hash
> > optimization and some testing, final decisions could be
> > made.
> 
> There are already far too many obscure CONFIGs. Don't add more.

And for people concerned about memory usage: There is always CONFIG_SMALL
for such decisions. Maybe one can limit worst case and average memory usage 
based on this config. The algorithm should stay the same.

Regards

Ingo Oeser
