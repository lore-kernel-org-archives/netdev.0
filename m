From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] af_mpls: fix undefined reference to ip6_route_output
Date: Thu, 23 Jul 2015 06:44:13 -0700
Message-ID: <55B0EFAD.1010007@cumulusnetworks.com>
References: <20150722.130444.1245167673786115378.davem@davemloft.net> <20150722201729.GB26717@pox.localdomain> <55AFFF47.8040704@cumulusnetworks.com> <20150723.000949.1617391267827343249.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:34660 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752358AbbGWNoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 09:44:16 -0400
Received: by pdbbh15 with SMTP id bh15so111810958pdb.1
        for <netdev@vger.kernel.org>; Thu, 23 Jul 2015 06:44:15 -0700 (PDT)
In-Reply-To: <20150723.000949.1617391267827343249.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/23/15, 12:09 AM, David Miller wrote:
> From: roopa <roopa@cumulusnetworks.com>
> Date: Wed, 22 Jul 2015 13:38:31 -0700
>
>> I cant think of a way to fix the current problem with my patch...
> I guess it's not obvious that adding CONFIG_MPLS_IPV6 would solve
> the problem perfectly.
I  thought that was not an option because CONFIG_MPLS_ROUTING is already 
out and supports IPV6 when RTA_OIF is
specified.

I did submit another version yesterday using IS_BUILTIN (sorry missed 
the v2 in the patch prefix).
https://patchwork.ozlabs.org/patch/498903/

I can certainly introduce CONFIG_MPLS_IPV6, if that is a more acceptable.

thanks.
