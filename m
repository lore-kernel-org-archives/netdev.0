From: Julian Anastasov <ja@ssi.bg>
Subject: Re: multipath routing doesn't work with netlink
Date: Tue, 29 Oct 2002 01:31:22 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210290117330.1667-100000@u.domain.uli>
References: <Pine.LNX.4.44L.0210282102150.1697-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>,
   Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rik van Riel <riel@conectiva.com.br>
In-Reply-To: <Pine.LNX.4.44L.0210282102150.1697-100000@imladris.surriel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Mon, 28 Oct 2002, Rik van Riel wrote:

> "ip route prepend" doesn't work here, but "ip route append" does
> exactly what is wanted.

	Try harder, it should work. Of course, append/prepend
fail too if the same route exists, they simply use different
keys for route uniqueness.

Regards

--
Julian Anastasov <ja@ssi.bg>
