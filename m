From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] Implementation for IPv6 MIB:ipv6AddressTable
Date: Tue, 7 Oct 2003 15:16:20 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310071116.PAA30760@yakov.inr.ac.ru>
References: <20031007034051.3fcb3218.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mashirle@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20031007034051.3fcb3218.davem@redhat.com> from "David S. Miller" at ïËÔ 07, 2003 03:40:51 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Do you think it is large enough for timestamp? :)

If it is not, "unsigned long" is not enough either.

Actually, this does not depend on our implementation. If people implement
a MIB, required precision of these times is prescribed in the rfc.
And this is definitely not jiffies.

Alexey
