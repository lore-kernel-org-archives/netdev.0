From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] Implementation for IPv6 MIB:ipv6AddressTable
Date: Tue, 7 Oct 2003 14:38:50 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310071038.OAA30009@yakov.inr.ac.ru>
References: <200310011637.27013.mashirle@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mashirle@us.ibm.com (Shirley Ma)
In-Reply-To: <200310011637.27013.mashirle@us.ibm.com> from "Shirley Ma" at ïËÔ 01, 2003 04:37:26 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> +=09unsigned long=09cstamp; /* created time */
> +=09unsigned long=09tstamp; /* updated time */

Please, do not use "long" things, they are not allowed in API.
u32 would be good.

Alexey
