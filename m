From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] IPv6: Improvement of Source Address Selection
Date: Sat, 28 Sep 2002 08:19:29 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209280419.IAA02894@sex.inr.ac.ru>
References: <20020927.203606.32735488.davem@redhat.com>
Mime-Version: 1.0
Cc: yoshfuji@linux-ipv6.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20020927.203606.32735488.davem@redhat.com> from "David S. Miller" at Sep 27, 2 08:36:06 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Alexey, I still am not clear, this belongs in the output routing logic
> right?
...
> where source address selection belongs.

Yes, it naturally belongs to the time when route is created.

This is just extending ipv6 routing entry with a field to hold
source address and, generally, making the same work as IPv4 does,
with all the advantages, particularily capability to select preferred
source address via routes set up by admin (RTA_PREFSRC attribute,
"src" in "ip route add").

Alexey
