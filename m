From: Julian Anastasov <ja@ssi.bg>
Subject: Re: multipath routing doesn't work with netlink
Date: Mon, 28 Oct 2002 22:54:44 +0000 (GMT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210282228120.1369-100000@u.domain.uli>
References: <Pine.LNX.4.44L.0210281407540.22494-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>,
   Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rik van Riel <riel@conectiva.com.br>
In-Reply-To: <Pine.LNX.4.44L.0210281407540.22494-100000@duckman.distro.conectiva>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Mon, 28 Oct 2002, Rik van Riel wrote:

> Am I doing something wrong or is there a kernel bug that
> prevents multipath routing from working with NETLINK ?

	Not bug but a hidden feature :) You can define
alternative default routes with "ip route append".

> # ip route add default via 10.0.16.1
> # ip route add default via 10.0.17.2
> RTNETLINK answers: File exists

	And this is "ip route prepend" (NLM_F_REQUEST|NLM_F_CREATE
without NLM_F_APPEND):

> # route add default gw 10.0.17.2
> #

> Is there a fundamental reason that iproute2 (using NETLINK) should
> fail here, or is this a bug for which patches will be accepted ?

	You can reach exactly the text explaining these features
by searching for "prepend" in ip-cref.tex. Note that the paragraph
recommends to avoid them, may be something that Alexey will change
one day :)

> regards,
>
> Rik

Regards

--
Julian Anastasov <ja@ssi.bg>
