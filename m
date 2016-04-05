From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v3 4/4] vxlan: implement GPE
Date: Tue, 5 Apr 2016 15:57:12 +0200
Message-ID: <20160405155712.3e8a578e@griffin>
References: <cover.1459860270.git.jbenc@redhat.com>
	<2f2080cbe948be319e5725b2aa484e8996ed36ae.1459860270.git.jbenc@redhat.com>
	<CALx6S35gFDe+hiOtQqDUuzahkeh7vB3du3TN=noYefuDNGmCJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jesse Gross <jesse@kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44097 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752957AbcDEN5Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 09:57:16 -0400
In-Reply-To: <CALx6S35gFDe+hiOtQqDUuzahkeh7vB3du3TN=noYefuDNGmCJw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 5 Apr 2016 10:50:57 -0300, Tom Herbert wrote:
> I requested input from VXLAN protocol experts on whether RCO is
> architecturally correct in VXLAN and whether we are using the right
> fields both on the mailing list and in WG meeting yesterday @IETF.
> Have not gotten any response, so I am going to assume all this is
> reasonable. I will add explicit support to VXLAN-RCO draft for
> VXLAN-GPE. The configuration option for RX RCO can be removed and RCO
> can be supported for VXLAN/VXLAN-GPE in same way. Presumably, GBP
> might make same assumptions but GBP format as defined for VXLAN isn't
> compatible with VXLAN-GPE.

Cool, thanks! We'll loosen the restriction after it's added to the RFC,
it should be a simple one line patch.

 Jiri
