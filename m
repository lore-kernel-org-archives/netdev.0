From: Florian Westphal <fw@strlen.de>
Subject: Re: iptables problem upgrading kernel from 3.18.8 to 3.19.1
Date: Sun, 8 Mar 2015 18:55:53 +0100
Message-ID: <20150308175553.GA1528@breakpoint.cc>
References: <54FC2089.6080809@unsolicited.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pablo@netfilter.org, stable@kernel.org
To: David R <david@unsolicited.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:41216 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753055AbbCHRz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Mar 2015 13:55:57 -0400
Content-Disposition: inline
In-Reply-To: <54FC2089.6080809@unsolicited.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David R <david@unsolicited.net> wrote:

[ CC Pablo & stable@ ]

> I've just had an exception to my "uneventful kernel upgrade" monotony.
> 
> My boot scripts failed when setting up the firewall due to this :-
> 
>     xt_recent: hitcount (1) is larger than packets to be remembered (1)
> for table xxxx
> 
> This is a completely straightforward
> 
>     iptables -A yyyy -j REJECT -p tcp --reject-with tcp-reset -m recent
> --set --name xxxx --rsource
> 
> Looking at the history for xt_recent.c it looks like this was introduced
> in abc86d0f99242b7f142b7cb8f90e30081dd3c256 but maybe corrected in
> cef9ed86ed62eeffcd017882278bbece32001f86 ?

Right.  I would recommend to revert abc86d0f99242b7f142b7cb8f90e30081dd3c256
in 3.19.y series rather than applying cef9ed86ed62, though.

Sorry,
Florian
