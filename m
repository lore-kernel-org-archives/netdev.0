From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH]  IPv6 Prefix List support for 2.5.31
Date: Thu, 29 Aug 2002 04:32:22 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200208290032.EAA25255@sex.inr.ac.ru>
References: <OF37F86F02.E05B3694-ON88256C23.0080D178@boulder.ibm.com>
Mime-Version: 1.0
Cc: linux-net@vger.kernel.org, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kumarkr@us.ibm.com (Krishna Kumar)
In-Reply-To: <OF37F86F02.E05B3694-ON88256C23.0080D178@boulder.ibm.com> from "Krishna Kumar" at Aug 28, 2 04:55:35 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> - Routing table will have lots of address prefixes that are not available
>   to the local interface addresses.

Well, all the direct routes are prefixes by definition.


> - To be a prefix list entry, it should come via an RA.

Wrong. But this does not matter, RA routes may be tagged with a flag.


> -  Also, the search over a longer routing table across all nodes is more
>    time consuming.

Do you jest? You compare linear search with lookup in radix tree. :-)

Alexey
