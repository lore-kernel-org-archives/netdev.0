From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: enable/disable temporary IPv6 per prefix
Date: Mon, 12 Sep 2016 17:15:12 +0200
Message-ID: <9d628878-0432-1a41-1877-0dd46ae0932a@stressinduktion.org>
References: <74afa986-01e5-729e-8847-2181f576893f@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Oliver Mangold <o.mangold@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:40735 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933127AbcILPPO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 11:15:14 -0400
In-Reply-To: <74afa986-01e5-729e-8847-2181f576893f@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11.09.2016 09:29, Oliver Mangold wrote:
> Hi,
> 
> I have a question as a relatively new user to IPv6. I am wondering if it
> is currently possible to enable/disable the usage of temporary addresses
> on a per-prefix basis. My current understanding is that the feature is
> enabled by the the 'use_tempaddr' sysctl attribute, which is
> per-interface. What I would like to do is disable temp addresses for ULA
> prefixes. Did I miss something and this can already be done, or is it a
> feature planned for the future, maybe? RFC4941 seems to agree that this
> is a valid use case:
> 
> 
> Additionally, sites might wish to selectively enable or disable the use
> of temporary addresses for some prefixes.  For example, a site might
> wish to disable temporary address generation for "Unique local" [ULA]
> prefixes while still generating temporary addresses for all other global
> prefixes.  Another site might wish to enable temporary address
> generation only for the prefixes 2001::/16 and 2002::/16, while
> disabling it for all other prefixes. To support this behavior,
> implementations SHOULD provide a way to enable and disable generation of
> temporary addresses for specific prefix subranges.  This per-prefix
> setting SHOULD override the global settings on the node with respect to
> the specified prefix subranges.  Note that the pre-prefix setting can be
> applied at any granularity, and not necessarily on a per-subnet basis.

We don't support such a feature (yet). I think NetworkManager also
doesn't implement it so far.

Bye,
Hannes
