From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH][INET] move inet_sock into inet_opt and rename it to inet_sock
Date: Mon, 27 Dec 2004 23:06:57 -0200
Message-ID: <200412272306.58203.acme@conectiva.com.br>
References: <41CE198B.7040005@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <41CE198B.7040005@conectiva.com.br>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em S=E1b 25 Dez 2004 23:53, voc=EA escreveu:
> Hi David,
>
> 	Now that 2.6.10 is out, please take a look if this is acceptable,
> the following patches will deal with udp_sock, tcp_sock, etc.
>
> 	This is the start of the series of patches that will introduce
> struct connection_sock, reducing the memory used by non connected
> protocols, such as UDP.
>
> 	It is available at:
>
> bk://kernel.bkbits.net/acme/connection_sock-2.6

Dave, wait a while, I've just tried it with current BK, after Linus merge=
d
your 2.6.11 netdev queue and it breaks with things like Stephen's TCP
ephemeral port changesets...

- Arnaldo
