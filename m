From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Fri, 04 Jul 2008 14:48:24 +0100
Message-ID: <1215179304.10393.777.camel@pmac.infradead.org>
References: <1215093175.10393.567.camel@pmac.infradead.org>
	 <20080703173040.GB30506@mit.edu>
	 <1215111362.10393.651.camel@pmac.infradead.org>
	 <20080703.162120.206258339.davem@davemloft.net>
	 <486D6DDB.4010205@infradead.org> <87ej6armez.fsf@basil.nowhere.org>
	 <1215177044.10393.743.camel@pmac.infradead.org>
	 <486E2260.5050503@garzik.org>
	 <1215178035.10393.763.camel@pmac.infradead.org>
	 <486E2818.1060003@garzik.org> <20080704142753.27848ff8@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, tytso@mit.edu,
	hugh@veritas.com, akpm@linux-foundation.org,
	kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:49274 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753480AbYGDNst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 09:48:49 -0400
In-Reply-To: <20080704142753.27848ff8@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-07-04 at 14:27 +0100, Alan Cox wrote:
> > Why is it so difficult to see the value of KEEPING STUFF WORKING AS
> IT 
> > WORKS TODAY?
> 
> Sure Jeff. Lets delete libata, that caused all sorts of problems when
> it was being added.

A particularly good example. I used to be able to just copy around the
driver for my host controller. Now I have to copy _two_ files, so the
world is going to end! Should I have insisted that we link libata
statically into each and every module which uses it?

(Or at least I have to copy two files _if_ I actually want to make
changes to libata.ko too, which I almost never do...)

-- 
dwmw2

