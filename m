From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: multipath routing doesn't work with netlink
Date: Mon, 28 Oct 2002 21:04:17 -0200 (BRST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44L.0210282102150.1697-100000@imladris.surriel.com>
References: <Pine.LNX.4.44.0210282228120.1369-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>,
   Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0210282228120.1369-100000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 28 Oct 2002, Julian Anastasov wrote:
> On Mon, 28 Oct 2002, Rik van Riel wrote:
> > # ip route add default via 10.0.16.1
> > # ip route add default via 10.0.17.2
> > RTNETLINK answers: File exists
>
> 	And this is "ip route prepend" (NLM_F_REQUEST|NLM_F_CREATE
> without NLM_F_APPEND):

"ip route prepend" doesn't work here, but "ip route append" does
exactly what is wanted.

Thank you,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".
http://www.surriel.com/		http://distro.conectiva.com/
Current spamtrap:  <a href=mailto:"october@surriel.com">october@surriel.com</a>
