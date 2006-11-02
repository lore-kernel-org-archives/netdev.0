From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than d80211-specific
 qdisc
Date: Thu, 2 Nov 2006 14:48:33 -0800
Message-ID: <20061102144833.6a161b2b@freekitty>
References: <20061102193839.4884ae56@logostar.upir.cz>
	<C86180A8C204554D8A3323D8F6B0A29F018B5E78@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Jiri Benc" <jbenc@suse.cz>, "Sven-Haegar Koch" <haegar@sdinet.de>,
	"Christoph Hellwig" <hch@infradead.org>,
	"James Ketrenos" <jketreno@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Jeff Garzik" <jeff@garzik.org>,
	"Patrick McHardy" <kaber@trash.net>,
	"David Kimdon" <dwhedon@devicescape.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:44498 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1752336AbWKBWuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 17:50:05 -0500
To: "Simon Barber" <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F018B5E78@dhost002-46.dex002.intermedia.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2 Nov 2006 13:27:59 -0800
"Simon Barber" <simon@devicescape.com> wrote:

> Perhaps the solution is to allow the prefix to be a kernel configuration
> item?
> 
> Simon 

All modern distro's support device naming stuff through hotplug.
Don't put effort into keeping the kernel defaults absolute.

Please have Ethernet (and wireless) devices show up as eth%d. For the master device,
choose something else (mac%d ?).

-- 
Stephen Hemminger <shemminger@osdl.org>
