From: Scott Feldman <sfeldma@pobox.com>
Subject: Re: PROBLEM: kernel BUG at dev.c:998! - panic w/ uml/bridge and
	Intel 82562 (e100)
Date: 31 Oct 2003 10:09:01 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1067623740.2703.2.camel@localhost.localdomain>
References: <8a2645d5.d697cfd3.857ad00@mirapoint.uow.edu.au>
Reply-To: sfeldma@pobox.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Benjamin Low <benjamin@uow.edu.au>
In-Reply-To: <8a2645d5.d697cfd3.857ad00@mirapoint.uow.edu.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> [1.] panic when starting uml host with bridged networking on an Intel 
> 82562 (e100 driver)

This is probably the bridge bug that was fixed recently where the
skb->ip_summed field wasn't being clear from Rx to Tx through the
bridge.  Turn off Rx checksum offloading in e100 for temp fix.

-scott
