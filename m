From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] af_pppox: create module infrastructure for protocol modules
Date: Tue, 29 Apr 2003 04:12:19 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030429071218.GP25361@conectiva.com.br>
References: <20030429061227.GJ25361@conectiva.com.br> <20030428.222728.48508327.davem@redhat.com> <20030429.154651.108798316.yoshfuji@wide.ad.jp> <20030428.230045.21906184.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@wide.ad.jp, mostrows@speakeasy.net, netdev@oss.sgi.com,
   maxk@qualcomm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030428.230045.21906184.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Mon, Apr 28, 2003 at 11:00:45PM -0700, David S. Miller escreveu:
>    From: YOSHIFUJI Hideaki / ?$B5HF#1QL@ <yoshfuji@wide.ad.jp>
>    Date: Tue, 29 Apr 2003 15:46:51 +0900 (JST)
> 
>    We probably need to refer IPv4 module as well as IPv6 module 
>    because of the IPv4-Mapped address feature for IPv6 sockets.
>    
> Right.

This kind of subtlety is perfectly solved with the scheme now in DaveM's
tree for pppox, as the net family layer is where this kinds of special
cases are better handled.

I'll take a look at this and will try to come up with a patch.

- Arnaldo
