From: Rick Jones <rick.jones2@hp.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Wed, 22 Jun 2005 13:35:46 -0700
Message-ID: <42B9CBA2.5050208@hp.com>
References: <1119458226.6918.142.camel@localhost.localdomain>	<200506221801.j5MI11xS021866@guinness.s2io.com>	<20050622180654.GX14251@wotan.suse.de> <20050622.132241.21929037.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, becker@scyld.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050622.132241.21929037.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> Everyone seems to have this absolute fetish about batching the RX
> descriptor refilling work.  It's wrong, it should be done when you
> pull a receive packet off the ring, for many reasons.  Off the top of
> my head:
> 
> 1) Descriptors are refilled as soon as possible, decreasing
>    the chance of the device hitting the end of the RX ring
>    and thus unable to receive a packet.

IFF one pokes the NIC for each buffer right?

rick jones
