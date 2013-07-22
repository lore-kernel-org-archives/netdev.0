From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/2] ss: Fix compiler errors of unused
 return-values
Date: Mon, 22 Jul 2013 08:35:26 -0700
Message-ID: <20130722083526.236536fd@nehalam.linuxnetplumber.net>
References: <1374350298-1177-1-git-send-email-christoph.paasch@uclouvain.be>
	<1374350298-1177-2-git-send-email-christoph.paasch@uclouvain.be>
	<20130722075410.78532ad4@nehalam.linuxnetplumber.net>
	<CAHj3AVnrAvCZvzY00qsQodwyXSLF28bPWFJhRTnd5Ny=kZHyZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Christoph Paasch <christoph.paasch@uclouvain.be>,
	netdev@vger.kernel.org
To: Denis Kirjanov <kirjanov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:46435 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752125Ab3GVPf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 11:35:29 -0400
Received: by mail-pd0-f182.google.com with SMTP id r10so7005523pdi.27
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 08:35:28 -0700 (PDT)
In-Reply-To: <CAHj3AVnrAvCZvzY00qsQodwyXSLF28bPWFJhRTnd5Ny=kZHyZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 22 Jul 2013 19:06:11 +0400
Denis Kirjanov <kirjanov@gmail.com> wrote:

> Do we need the -Werror at all? I've found a similar discussion
> regarding building wil6210 driver with the same issue

I put Werror in because it stops people from adding new things that
have warnings.
