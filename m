From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch]: CONFIG_IPV6_SUBTREES fix for MIPv6
Date: Tue, 10 Jun 2003 09:51:35 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030610.095135.28806569.davem@redhat.com>
References: <Pine.GSO.4.44.0306091140470.25126-100000@morphine.tml.hut.fi>
	<20030609203659.089b241b.nakam@linux-ipv6.org>
	<3EE5F85E.9080006@tml.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nakam@linux-ipv6.org, lpetande@morphine.tml.hut.fi,
   yoshfuji@linux-ipv6.org, vnuorval@tcs.hut.fi, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com, ajtuomin@morphine.tml.hut.fi, jagana@us.ibm.com,
   kumarkr@us.ibm.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: lpetande@tml.hut.fi
In-Reply-To: <3EE5F85E.9080006@tml.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Henrik Petander <lpetande@tml.hut.fi>
   Date: Tue, 10 Jun 2003 18:25:18 +0300
   
   Then the policies for mipv6 would need to be specified at the same time 
   as the ipsec policies. This is not a problem as long as the policies are 
     loaded at start up. However, this could lead to problems with 
   applications which specify their own policies, e.g. racoon.

It is an important point.

Ask yourself this, why do we have tunnel devices and don't implement
them with cool routing or XFRM rules?  We don't do this because as
soon as you type "zebra" all your by-hand routes are gone, and as soon
as you type "racoon" al your by-hand xfrm rules are gone.

If you want to do these things using routes or xfrm rules, you must
integrate the creation of them into either zebra or racoon.  You
cannot have a setup where mipv6d and racoon/zebra fight each other
flushing each other's settings.  It doesn't work.
