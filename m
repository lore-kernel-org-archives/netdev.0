From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH][2.5.22] OOPS in tcp_v6_get_port
Date: Tue, 18 Jun 2002 13:43:21 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200206180943.NAA12296@sex.inr.ac.ru>
References: <20020617.143319.54623892.davem@redhat.com>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: davem@redhat.COM (David S. Miller)
In-Reply-To: <20020617.143319.54623892.davem@redhat.com> from "David S. Miller" at Jun 18, 2 01:45:00 am
List-Id: netdev.vger.kernel.org

Hello!

> This is a known bug introduced by the struct sock splitup into
> external per-protocol pieces done by Arnaldo de Melo.  He is working
> on the proper fix, your proposed change will just paper over the real
> bug.

I am afraid you speak about different bug.

Old code really relied on the fact that each IPv4 code has zeroed IPv6
part, and that each IPv6 socket has correctly intialized IPv4 part.

So, Carl's suggestion may be right. Each time when accesing IPv6 data
we have to check that it really exists (when we are not sure).

Alexey
