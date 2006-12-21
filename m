From: Matthew Garrett <mjg59@srcf.ucam.org>
Subject: Re: Network drivers that don't suspend on interface down
Date: Thu, 21 Dec 2006 03:25:47 +0000
Message-ID: <20061221032547.GB1277@srcf.ucam.org>
References: <20061220042648.GA19814@srcf.ucam.org> <20061220144906.7863bcd3@dxpl.pdx.osdl.net> <20061221011209.GA32625@srcf.ucam.org> <200612202105.31093.flamingice@sourmilk.net> <20061221021832.GA723@srcf.ucam.org> <4589F39C.7010201@gentoo.org> <20061221024533.GA1025@srcf.ucam.org> <4589FAA6.509@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Wu <flamingice@sourmilk.net>,
	Stephen Hemminger <shemminger@osdl.org>,
	Arjan van de Ven <arjan@infradead.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cavan.codon.org.uk ([217.147.92.49]:39798 "EHLO
	vavatch.codon.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422641AbWLUD0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Dec 2006 22:26:05 -0500
To: Daniel Drake <dsd@gentoo.org>
Content-Disposition: inline
In-Reply-To: <4589FAA6.509@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 20, 2006 at 10:08:22PM -0500, Daniel Drake wrote:
> Matthew Garrett wrote:
> >Hm. Does the spec not set any upper bound on how long it might take for 
> >APs to respond? I'm afraid that my 802.11 knowledge is pretty slim. 
> 
> I'm not sure, but thats not entirely relevant either.  The time it takes 
> for the AP to respond is not related to the delay between userspace 
> sending the siwscan and giwscan ioctls (unless you're thinking of 
> userspace being too quick, but GIWSCAN already returns -EINPROGRESS when 
> appropriate so this is detectable)

Ah - I've mostly been looking at the ipw* drivers, where giwscan just 
seems to return information cached by the ieee80211 layer. A quick scan 
suggests that most cards behave like this, but prism54 seems to refer to 
the hardware. I can see why that would cause problems.

> I think it's reasonable to keep the interface down, but then when the 
> user does want to connect, bring the interface up, scan, present scan 
> results. Scanning is quick, there would be minimal wait needed here.

Yeah, that's true.

-- 
Matthew Garrett | mjg59@srcf.ucam.org
