From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH V2 net-next] LISP: Locator/Identifier Separation Protocol
Date: Tue, 17 Jun 2014 14:43:26 -0700
Message-ID: <CA+mtBx-dvUa6cWj+4QZ00RdQc3qYb3tXf-74cSA89Xxegxv7-w@mail.gmail.com>
References: <4D3092DF-BB04-4C50-88B9-EBBA349C7B17@logicalelegance.com>
	<CA+mtBx9OdgWad6WJvNoUWreoyef9sd0AbHAsNWTSHaD1z=Tj8A@mail.gmail.com>
	<5F3B797F-9DE9-43AC-91E1-C11B51DB2B2C@logicalelegance.com>
	<CA+mtBx9-iJjuCrL2J+jzcnztvVJsFjccs_FKO1z33HRkSw2PRg@mail.gmail.com>
	<D412AF6C-7930-48E1-B4AD-FB4E7588460E@logicalelegance.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"Vina Ermagan (vermagan)" <vermagan@cisco.com>,
	"Lorand Jakab -X (lojakab - M SQUARED CONSULTING INC. at Cisco)"
	<lojakab@cisco.com>
To: Christopher White <chris@logicalelegance.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:37167 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965209AbaFQVn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 17:43:26 -0400
Received: by mail-ig0-f178.google.com with SMTP id hn18so95044igb.5
        for <netdev@vger.kernel.org>; Tue, 17 Jun 2014 14:43:26 -0700 (PDT)
In-Reply-To: <D412AF6C-7930-48E1-B4AD-FB4E7588460E@logicalelegance.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 17, 2014 at 2:37 PM, Christopher White
<chris@logicalelegance.com> wrote:
>
> On Jun 17, 2014, at 1:52 PM, Tom Herbert <therbert@google.com> wrote:
>
>
> In udp.c perhaps? udp_tunnel_create_v4_sock()?
>
> It might make sense for this to udp_offload.c (along with
> skb_udp_tunnel_segment).
>
>
> skb_udp_tunnel_segment() is currently in udp.c, do you want me to move it to
> udp_offload.c?
>
Yes, please do.

> -Chris
>
