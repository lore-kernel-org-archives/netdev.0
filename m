From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Fri, 04 Jul 2008 14:46:01 +0100
Message-ID: <1215179161.10393.773.camel@pmac.infradead.org>
References: <1215093175.10393.567.camel@pmac.infradead.org>
	 <20080703173040.GB30506@mit.edu>
	 <1215111362.10393.651.camel@pmac.infradead.org>
	 <20080703.162120.206258339.davem@davemloft.net>
	 <486D6DDB.4010205@infradead.org>  <87ej6armez.fsf@basil.nowhere.org>
	 <1215177044.10393.743.camel@pmac.infradead.org>
	 <486E2260.5050503@garzik.org>
	 <1215178035.10393.763.camel@pmac.infradead.org>
	 <486E2818.1060003@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, tytso@mit.edu,
	hugh@veritas.com, akpm@linux-foundation.org,
	kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:58053 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753057AbYGDNqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 09:46:20 -0400
In-Reply-To: <486E2818.1060003@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-07-04 at 09:39 -0400, Jeff Garzik wrote:
> You have been told repeatedly that cp(1) and scp(1) are commonly used
> to transport the module David and I care about -- tg3.  It's been a
> single file module since birth, and people take advantage of that
> fact.

And you can _continue_ to do that. You'd need to install the firmware
just once, and that's all. It's a non-issue, and it isn't _worth_ the
added complexity of building the firmware into the module.

_Especially_ since I strongly suspect you'll come back with an even
sillier argument if we do.

Like claiming that you also run 'grep request_firmware tg3.ko' and your
scripts will fail if it matches...

-- 
dwmw2

