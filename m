From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v4 2/2] ss: support closing inet sockets via
 SOCK_DESTROY.
Date: Mon, 18 Jan 2016 11:48:28 -0800
Message-ID: <20160118114828.2497a0f6@xeon-e3>
References: <CAKD1Yr1VQxVkQKpGxrtGmWd=_Z9Q2eBp1L313bqSddDXG9nNxg@mail.gmail.com>
	<1452241957-18854-1-git-send-email-lorenzo@google.com>
	<1452241957-18854-3-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	zenczykowski@gmail.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35521 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754270AbcARTsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2016 14:48:21 -0500
Received: by mail-pf0-f180.google.com with SMTP id 65so162241797pff.2
        for <netdev@vger.kernel.org>; Mon, 18 Jan 2016 11:48:21 -0800 (PST)
In-Reply-To: <1452241957-18854-3-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  8 Jan 2016 17:32:37 +0900
Lorenzo Colitti <lorenzo@google.com> wrote:

> This patch adds a -K / --kill option to ss that attempts to
> forcibly close matching sockets using SOCK_DESTROY.
> 
> Because ss typically prints sockets instead of acting on them,
> and because the kernel only supports forcibly closing some types
> of sockets, the output of -K is as follows:
> 
> - If closing the socket succeeds, the socket is printed.
> - If the kernel does not support forcibly closing this type of
>   socket (e.g., if it's a UDP socket, or a TIME_WAIT socket),
>   the socket is silently skipped.
> - If an error occurs (e.g., permission denied), the error is
>   reported and ss exits.
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

Both applied, thanks
