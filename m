From: kuznet@ms2.inr.ac.ru
Subject: Re: Change proxy_arp to respond only for valid neighbours
Date: Thu, 12 Feb 2004 22:37:38 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402121937.WAA10800@yakov.inr.ac.ru>
References: <Pine.LNX.4.58.0402121116050.1399@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ja@ssi.bg (Julian Anastasov)
In-Reply-To: <Pine.LNX.4.58.0402121116050.1399@u.domain.uli> from "Julian Anastasov" at Feb 12, 2004 11:46:37 AM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

Joining the discussion too late, but let me to reformulate original
Jamal's question in another way: are you aware that you relay _broadcast_
ARP requests doing the validation?

I really like the idea, but this aspect bothers me a lot. Is it not storm
unsafe? Look, earlier broadcasts on outgoing interface started only when
a real unicast IP traffic was pending, so we were sure sender selected some
single proxy router, now broadcasts will be sent by _all_ the routers. See?

Alexey
