From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: support of IPv6 by NFS
Date: Wed, 02 Mar 2005 00:42:45 +0900 (JST)
Message-ID: <20050302.004245.114793740.yoshfuji@linux-ipv6.org>
References: <42243F8D.5030302@bull.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-ipv6@list.f00f.org, gh@us.ibm.com,
        Tony.Reix@bull.net, yoshfuji@linux-ipv6.org
To: gilles.quillard@bull.net
In-Reply-To: <42243F8D.5030302@bull.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <42243F8D.5030302@bull.net> (at Tue, 01 Mar 2005 11:10:21 +0100), Gilles Quillard <gilles.quillard@bull.net> says:

> The problem is not specific to NFS, any networking application written 
> using IPv6 mechanisms for both IPv4 and IPv6 addresses (AF_INET6 socket 
> opened, IPv4 addresses mapped) couldn't work without a kernel built with 
> IPv6.
:
> Are the final users really against the use of kernels built with IPv6 ?
> What is preconized on Linux for the support of IPv6 ? The solution
> described above or the cohabitation of the two modes (struct sockaddr or
> sockaddr_storage used to contain either struct sockaddr_in or struct
> sockaddr_in6) with specific processing according to the family of the
> addresses ?

You cannot assume whether the user enables IPv6 or not,
and you cannot assume s/he has connectivity to global Internet,
in most cases.

So, you likely need to try both IPv6 and IPv4.
Getaddrinfo() / getnameinfo(), or "protocol independent progarmming," 
are your friend.

--yoshfuji
