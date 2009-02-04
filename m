From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [PATCH] [RESEND] iproute2 : invalid burst/cburst calculation with hrtimers
Date: Thu, 5 Feb 2009 00:26:46 +0200
Message-ID: <200902050026.46603.denys@visp.net.lb>
References: <200902021926.17768.denys@visp.net.lb> <498A0699.6020103@gmail.com> <498A0E4A.8050807@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:36274 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757539AbZBDW04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 17:26:56 -0500
In-Reply-To: <498A0E4A.8050807@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 04 February 2009 23:53:14 Jarek Poplawski wrote:
> Jarek Poplawski wrote, On 02/04/2009 10:20 PM:
> > Denys Fedoryschenko wrote, On 02/02/2009 07:21 PM:
> >> Why floating point?
> >
> > Yes, floating point is not enough. get_hz() == 1000000000 could be
> > a theoretical resolution, but I guess we don't expect to use this,
> > even if it were possible. Since high resolution can schedule more
> > often than 1000HZ, it seems these buffers could be set lower (10x,
> > 100x?), but there should be some reasonable limit.
>
> Anyway, it's rather a matter of tweaking. IMHO 1000HZ limit for setting
> these defaults looks safe, so I think this patch is OK.
>
> Jarek P.
Maybe we can put note in documentation or even htb help output, that user can 
increase precision with hrtimers enabled, by setting HZ variable?
