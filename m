From: "David S. Miller" <davem@redhat.com>
Subject: Re: multicast loop with include filters fix [PATCH]
Date: Thu, 22 Jan 2004 17:57:05 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040122.175705.71096838.davem@redhat.com>
References: <OF56B39506.D81AEE48-ON88256E24.000A2D7B@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, stevenh@xsmail.com
Return-path: <netdev-bounce@oss.sgi.com>
To: dlstevens@us.ibm.com
In-Reply-To: <OF56B39506.D81AEE48-ON88256E24.000A2D7B@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: David Stevens <dlstevens@us.ibm.com>
   Date: Thu, 22 Jan 2004 19:02:07 -0700

   When sending a multicast and using looping back a copy to the
   local machine, the interface filter checks can be done before the
   source address is specified. For an INCLUDE filter, this won't match
   the allowed sources and the packets won't be delivered locally,
   even when the ultimate source address chosen is in the allowed list.
   
   The patch below fixes the filter checks for both IGMPv3 and MLDv2
   to only apply when a source address is available.

Looks good, I guess a 2.4.x variant is forthcoming?

Thanks.
