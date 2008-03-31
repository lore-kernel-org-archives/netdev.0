From: "Julius Volz" <juliusv@google.com>
Subject: Re: Adding IPv6 support to IPVS: some general questions about kernel development
Date: Mon, 31 Mar 2008 20:29:30 +0200
Message-ID: <f4845fc0803311129w4bdb0415p56c3f11c935c3020@mail.gmail.com>
References: <f4845fc0803310753o56ccbae5uda1e216fa139857@mail.gmail.com>
	 <47F123C5.70804@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Simon Horman" <horms@verge.net.au>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:9702 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752667AbYCaS3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 14:29:36 -0400
Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id m2VITWN1022017
	for <netdev@vger.kernel.org>; Mon, 31 Mar 2008 11:29:32 -0700
Received: from rn-out-0910.google.com (rnge13.prod.google.com [10.38.207.13])
	by zps75.corp.google.com with ESMTP id m2VITVU5025758
	for <netdev@vger.kernel.org>; Mon, 31 Mar 2008 11:29:31 -0700
Received: by rn-out-0910.google.com with SMTP id e13so662919rng.16
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2008 11:29:31 -0700 (PDT)
In-Reply-To: <47F123C5.70804@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 31, 2008, Patrick McHardy <kaber@trash.net> wrote:
>  net/ipvs or net/netfilter/ipvs sound fine. The second is probably
>  better since at some point we should try to merge the duplicated
>  conntrack functionality if possible.

Sure, since IPVS is basically a netfilter extension, that sounds good
to me. Could all the IPv4- and IPv6-specific functionality (as opposed
to the commonly used code) also end up in there or would that still
have to reside under ipv[4,6]/...?

Does it seem wise to do this move as the first thing in this process?
That would probably be a good starter exercise to get to know the
whole process!

Thanks so much for helping!

Kind Regards,
Julius

-- 
Google Switzerland GmbH
