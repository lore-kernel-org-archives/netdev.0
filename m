From: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Subject: Re: [PATCH 0/7] TCP CUBIC Hystart fixes
Date: Tue, 22 Mar 2011 12:35:42 +0100
Message-ID: <20110322113542.GB21254@xanadu.blop.info>
References: <20110314175211.788224699@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S\. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xanadu.blop.info ([178.79.145.134]:50353 "EHLO xanadu.blop.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754804Ab1CVLfo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2011 07:35:44 -0400
Content-Disposition: inline
In-Reply-To: <20110314175211.788224699@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/03/11 at 10:52 -0700, Stephen Hemminger wrote:
> This is the merge of my patches and recent update Sangtae.
> It addresses the problems reported by Lucas Nussbaum that Hystart cau=
ses
> poor startup performance over links with lots of buffering.

What do you plan to do regarding stable kernels? We should probably
either push that patch serie, or disable hystart if HZ < 1000.
--=20
| Lucas Nussbaum             MCF Universit=E9 Nancy 2 |
| lucas.nussbaum@loria.fr         LORIA / AlGorille |
| http://www.loria.fr/~lnussbau/  +33 3 54 95 86 19 |
