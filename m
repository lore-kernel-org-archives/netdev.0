From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: Sockets from kernel space?
Date: Wed, 15 Dec 2004 23:06:19 -0200
Message-ID: <41C0DF8B.2020007@conectiva.com.br>
References: <41C0E720.8050201@comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Richard Moser <nigelenki@comcast.net>
In-Reply-To: <41C0E720.8050201@comcast.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

John Richard Moser wrote:
> -----BEGIN PGP SIGNED MESSAGE----- 
> Is it possible to create socket connections (AF_UNIX for example) from
> the kernel to local user processes that are listen()ing?
> 
> A good link to somewhere to help with this would be nice.

Please send networking development related messages to netdev@oss.sgi.com,
there are several networking hackers that don't even subscribe lkml.

Having said that, look at the svc_makesock and svc_create_socket functions
in net/sunrpc/svcsock.c as a starting point.

- Arnaldo
