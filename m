From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [NETFILTER]: Introduce nf_inet_address
Date: Sat, 23 Feb 2008 07:37:46 +0900
Message-ID: <1203719866.5771.81.camel@shinybook.infradead.org>
References: <200801291316.m0TDGivY024953@hera.kernel.org>
	 <1203428949.3223.25.camel@shinybook.infradead.org>
	 <47BAE13D.4060206@trash.net>
	 <1203431447.3223.33.camel@shinybook.infradead.org>
	 <47BAEB6C.1030609@trash.net>
	 <1203666762.5771.35.camel@shinybook.infradead.org>
	 <47BEE31D.7020003@trash.net> <47BEEC5C.4060201@netfilter.org>
	 <47BEEDEF.5060503@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, netdev@vger.kernel.org,
	Jan Engelhardt <jengelh@computergmbh.de>,
	"David S. Miller" <davem@davemloft.net>, varekova@redhat.com,
	twoerner@redhat.com,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <47BEEDEF.5060503@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Fri, 2008-02-22 at 16:44 +0100, Patrick McHardy wrote:
> Pablo Neira Ayuso wrote:
> > Patrick McHardy wrote:
> >> Yes, that was a bug in the lastest release. We need to
> >> release a 1.4.1 version or something like that, but I'm
> >> not too familiar with the release process, so I haven't
> >> done this so far.
> > 
> > I can schedule one for this weekend, just send me an ACK.
> 
> 
> That would be great. I think we had another issue in 1.4.0 with
> some header files, but I can't remeber the details.

If you are going to include header files in the release (which makes a
certain amount of sense), it would be best if those are simply the
result of the kernel's 'make headers_install', without any manual
changes.

-- 
dwmw2

