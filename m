From: "David S. Miller" <davem@redhat.com>
Subject: Re: [ANNOUNCE] NF-HIPAC: High Performance Packet Classification
 for Netfilter
Date: Thu, 26 Sep 2002 13:52:59 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020926.135259.62665945.davem@redhat.com>
References: <20020925.224001.99456805.davem@redhat.com>
	<Mutt.LNX.4.44.0209270122570.12511-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, nf@hipac.org, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@intercode.com.au
In-Reply-To: <Mutt.LNX.4.44.0209270122570.12511-100000@blackbird.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: James Morris <jmorris@intercode.com.au>
   Date: Fri, 27 Sep 2002 01:27:41 +1000 (EST)
   
   So, this could be used for generic network layer encapsulation, and be 
   used for GRE tunnels, SIT etc. without the kinds of kludges currently in 
   use?  Sounds nice.

Such IPIP tunnels have very real problems though, since only 64-bits
of packet quoting are required in ICMP errors, it is often impossible
to deal with PMTU requests properly, see "#ifndef
I_WISH_WORLD_WERE_PERFECT" in net/ipv4/ip_gre.c
