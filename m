From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] sk_reuse fixes
Date: Wed, 08 Dec 2004 14:14:09 +0100 (CET)
Message-ID: <20041208.141409.103464255.yoshfuji@linux-ipv6.org>
References: <fcb9aa29041208045671633835@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: ilya.pashkovsky@gmail.com
In-Reply-To: <fcb9aa29041208045671633835@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

In article <fcb9aa29041208045671633835@mail.gmail.com> (at Wed, 8 Dec 2004 14:56:31 +0200), Ilya Pashkovsky <ilya.pashkovsky@gmail.com> says:

> This fixes sk_reuse checks:
> 1) allow outgoing connections AND one listening socket bound to same
> source port.
> 2) remove > 1 check of a boolean variable

Two comments:

1. This (boolean variable) is not the case on Linux.
   Behavior is differentiated with sk_reuse > 1.
2. Please provide tcp_ipv6 part as well.

--yoshfuji
