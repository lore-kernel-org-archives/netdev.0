From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] xfrm ip6ip6
Date: Sun, 01 Jun 2003 01:34:52 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030601.013452.68050592.davem@redhat.com>
References: <87fzmv5ejc.wl@karaba.org>
	<Mutt.LNX.4.44.0306010158450.7298-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mk@linux-ipv6.org, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@intercode.com.au
In-Reply-To: <Mutt.LNX.4.44.0306010158450.7298-100000@excalibur.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: James Morris <jmorris@intercode.com.au>
   Date: Sun, 1 Jun 2003 02:01:42 +1000 (EST)

   We need to either filter them out or make sure they are 
   displayed as ipip.
   
   Part of the answer will depend on whether we want to expose xfrm-based 
   ipip tunnels for general use, or only use them internally for ipcomp.
   
I think it is an error to extend PF_KEY for our Linux purposes.
Our API here is basically defined to be whatever is in KAME :-)

However, setkey should filter entries it does not understand.

Currently I see no use for exposing these tunnel transforms
outside of the kernel.  Mobile IPV6, if it decides to use
xfrm6_tunnel, can configure them itself in the kernel side support.
Or, if user side is more appropriate for MIPV6 access, we may allow
it to use xfrm netlink interface somehow.
