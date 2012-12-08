From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] inet_diag: fix oops for IPv4 AF_INET6 TCP SYN-RECV state
Date: Fri, 7 Dec 2012 22:36:41 -0500
Message-ID: <CADVnQy=NRvxwdLUC13m=Qdm_rD+AF=YVDxeKcvF7=-xxvYghtA@mail.gmail.com>
References: <1354808546-644-1-git-send-email-ncardwell@google.com>
	<20121207.132019.1647690876686095833.davem@davemloft.net>
	<CADVnQykWjmpiPrSpGmOPc_WuamRNK_eO_ZC_6Q_TktRN2ALWew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <edumazet@google.com>, Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:48064 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932835Ab2LHDgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 22:36:42 -0500
Received: by mail-ie0-f179.google.com with SMTP id k14so2953563iea.38
        for <netdev@vger.kernel.org>; Fri, 07 Dec 2012 19:36:41 -0800 (PST)
In-Reply-To: <CADVnQykWjmpiPrSpGmOPc_WuamRNK_eO_ZC_6Q_TktRN2ALWew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 7, 2012 at 9:30 PM, Neal Cardwell <ncardwell@google.com> wrote:
> It also seems like it considers IPv4 and IPv6 with the same prefix as
> matching, which seems bogus; eg IMHO 128.0.0.0 should not match 1::/1.

Oops, I think my example should be "128.0.0.0 should not match 8000::/1".

>  In general it seems to me that a mismatch between entry->family and
> cond->family should prevent a match, except for the IPv4-mapped-IPv6
> case it already handles.

But I think that general issue still remains.

neal
