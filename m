From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: OSDL Bugzilla #2399: A user can remotely route a packet through eth0 on
 a Li
Date: Thu, 13 May 2004 12:10:41 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF9B67E38F.0A5372A0-ON88256E93.00625F59-88256E93.0063D1A2@us.ibm.com>
References: <20040513103139.08ebc779@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@oss.sgi.com, niv@us.ibm.com, "J. M." <snortwiz@hotmail.com>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040513103139.08ebc779@dell_ss3.pdx.osdl.net>
To: Stephen Hemminger <shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote on 05/13/2004 10:31:39 AM:

> The security model is correct, and well defined, just different than BSD
> derived systems.  It does conform to the standards (RFC's).

Stephen,
        This is not different from BSD behavior. IP has always used the
weak end-system model. The question for delivery is "is the destination
address a local address" (not just on the receiving interface). See WRS
"TCP/IP Illustrated" for relevant BSD code.

Re: security, Jared. If you want to restrict it, you can use netfilter
rules to drop packets targeted to the back-side interface of the one
you're receiving them on. bind() selects packets whose destination address
matches-- doesn't matter what interface they come in on. So, bind()
simply isn't the mechanism you want if you want it to be restricted to a
particular interface.

                                                +-DLS
