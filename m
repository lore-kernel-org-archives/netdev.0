From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Asserting ECN from userspace?
Date: Fri, 07 Oct 2011 10:25:43 -0700
Message-ID: <4E8F3617.5080001@hp.com>
References: <4E8BF6B2.6030101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bloat-devel@lists.bufferbloat.net
To: =?ISO-8859-1?Q?David_T=E4ht?= <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:32469 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932472Ab1JGRZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 13:25:45 -0400
In-Reply-To: <4E8BF6B2.6030101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/04/2011 11:18 PM, David T=E4ht wrote:
>
> No sooner had I noted (with pleasure) the kernel's new ability to
> correctly set the dscp bits on IPv6 TCP streams without messing with =
the
> negotiated ECN status, that I found several use cases where being abl=
e
> to assert ECN from userspace (for either ipv4, or ipv6) would be usef=
ul.
> ...
> 3) Web Proxies. A web proxy could note when it was experiencing
> congestion on one side of the proxied connection (or another) and sig=
nal
> the other side to slow down.
> ...
> As for 3... perhaps a grantable network capability? A proxy could
> acquire privs to twiddle those bits before dropping root privs.

=46or 3, couldn't/shouldn't the proxy simply stop draining the appropri=
ate=20
socket buffer to cause TCP's existing flow control to slow down that si=
de?

rick jones
