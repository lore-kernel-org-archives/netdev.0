From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Sun, 08 Jun 2003 05:05:00 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030608.050500.28795668.davem@redhat.com>
References: <87wuge59w2.fsf@deneb.enyo.de>
	<20030526.233211.54217447.davem@redhat.com>
	<87he70re62.fsf@deneb.enyo.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: fw@deneb.enyo.de
In-Reply-To: <87he70re62.fsf@deneb.enyo.de>
List-Id: netdev.vger.kernel.org

   From: Florian Weimer <fw@deneb.enyo.de>
   Date: Sun, 08 Jun 2003 13:39:49 +0200

   "David S. Miller" <davem@redhat.com> writes:
   
   > As a general purpose operating system, where people DO in fact use
   > these features quite regularly,
   
   Even non-CIDR netmasks?  AFAIK, it's hard to find dedicated networking
   devices (and routing protocols!) which support them. 8-/
   
Yes, people use source based routing to block specific IPs and
subnets, it's also needed to Mobile IPV4.

   Anyway, I've played a bit with something inspired by CEF (more
   precisely speaking, one diagram in the IOS internals book and some IOS
   diagnostic output).
   
Thanks, Alexey and myself will need to study this deeply.

Although, I hope it's not "too similar" to what CEF does because
undoubtedly Cisco has a bazillion patents in this area.  This is
actually an argument for coming up with out own algorithms without
any knowledge of what CEF does or might do. :(
