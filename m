From: kuznet@ms2.inr.ac.ru
Subject: Re: IPv6 MIB:ipv6PrefixTable implementation
Date: Tue, 2 Dec 2003 15:40:07 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200312021240.PAA01536@yakov.inr.ac.ru>
References: <200311191621.38087.mashirle@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, xma@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mashirle@us.ibm.com (Shirley Ma)
In-Reply-To: <200311191621.38087.mashirle@us.ibm.com> from "Shirley Ma" at Ноя 19, 2003 04:21:38 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> One implementation detail question, do you think I need to save all the o=
> ther=20
> Prefix Objects: Type, Origin(addrconf, manually, dhcp, others),

These two things should be stored right now. Existing implementation is
quite a mess, but we definitely want to remember origin of each route
in "protocol" and another flags, they are of common interest.


> AutonomoueFlag, AdvPreferredLiftTime and ValidLifeTime

ValidLifeTime is "expires" on this route.

What's about AdvPreferredLiftTime I am puzzled a little,
preferred time is not an attribute of a prefix at all,
it is attribute of address, is not it? Unless the prefix is used
to install local address it does not make sense, right?

Alexey
