From: "Thomas 'Dent' Mirlacher" <dent@cosy.sbg.ac.at>
Subject: Re: kern-25-net-core-bug
Date: Wed, 1 May 2002 20:35:37 +0200 (MET DST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.05.10205012032520.23254-100000@mausmaki.cosy.sbg.ac.at>
References: <200205011800.g41I0WwJ029694@oss.sgi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: d_vangreg <d.vangreg@inwind.it>
In-Reply-To: <200205011800.g41I0WwJ029694@oss.sgi.com>
List-Id: netdev.vger.kernel.org

--snip/snip

> I guessed (as errata):     ret=handle_diverter(skb);
> 
> & tried  (as corrige):     handle_diverter(skb);

well, a cleaner thing would be to set ret=0 or ret=
... but on the other hand, the return value for netif_receive_skb
isn't checked (at least in process_backlog)

btw. is someone auditing the network code?
- like check all return values from functions which could fail.

	++dent

-- 
in some way i do, and in some way i don't.
