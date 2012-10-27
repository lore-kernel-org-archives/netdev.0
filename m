From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: better retrans tracking for defer-accept
Date: Sat, 27 Oct 2012 14:27:06 -0400
Message-ID: <CADVnQynrVqFKOiqB7891hSKLZmQ0GXDiVypop75YB-6RYdjUtA@mail.gmail.com>
References: <1351238750-13611-1-git-send-email-subramanian.vijay@gmail.com>
	<1351339032.30380.222.camel@edumazet-glaptop>
	<alpine.LFD.2.00.1210271556250.1628@ja.ssi.bg>
	<1351344725.30380.286.camel@edumazet-glaptop>
	<1351347537.30380.315.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>,
	Vijay Subramanian <subramanian.vijay@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	Elliott Hughes <enh@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:41107 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758499Ab2J0S1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Oct 2012 14:27:07 -0400
Received: by mail-ie0-f174.google.com with SMTP id k13so5061120iea.19
        for <netdev@vger.kernel.org>; Sat, 27 Oct 2012 11:27:07 -0700 (PDT)
In-Reply-To: <1351347537.30380.315.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 27, 2012 at 10:18 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>

> @@ -2638,7 +2642,7 @@ static void get_openreq4(const struct sock *sk, const struct request_sock *req,
...
> -               req->retrans,
> +               req->num_retrans,
...
> @@ -1866,7 +1869,7 @@ static void get_openreq6(struct seq_file *seq,
...
> -                  req->retrans,
> +                  req->num_timeout,
...

There's a slight inconsistency in the changes to get_openreq4() and
get_openreq6() - the first now uses num_retrans and the second now
uses num_timeout.

Otherwise LGTM.

neal
