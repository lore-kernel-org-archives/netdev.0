From: "David S. Miller" <davem@redhat.com>
Subject: Re: snmp stats as %ld or %lu
Date: Thu, 03 Apr 2003 04:48:22 -0800 (PST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030403.044822.00469453.davem@redhat.com>
References: <20030402122755.5dc3f022.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: rddunlap@osdl.org
In-Reply-To: <20030402122755.5dc3f022.rddunlap@osdl.org>
List-Id: netdev.vger.kernel.org

   From: "Randy.Dunlap" <rddunlap@osdl.org>
   Date: Wed, 2 Apr 2003 12:27:55 +0000

   ipv4/proc.c prints SNMP stats using %lu,
   but ipv6/proc.c prints them using %ld.
   
   Is this difference intentional, planned, or an oversight,
   or something else?

Looks like an oversight to me, both should use the unsigned format.
