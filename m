From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC/PATCH] ICMPv6 MIB stats per-interface
Date: Mon, 14 Apr 2003 09:06:10 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030414.090610.117741299.davem@redhat.com>
References: <20030414080347.0af818f7.rddunlap@osdl.org>
	<20030415.002915.71906095.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: rddunlap@osdl.org, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030415.002915.71906095.yoshfuji@linux-ipv6.org>
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Tue, 15 Apr 2003 00:29:15 +0900 (JST)
   
   I'd recommend that we split information per interface
    1) to minimize the /proc file
    2) to minimize the effort to rewrite snmp daemon (e.g. net-snmp)
   We use /proc/net/dev_snmp6/{1,2,...}. Example:

I very much like this general idea.

But I want to suggest a different naming scheme.  Let us follow the
lead of things like /proc/sys/net/ipv4/conf/ where subfiles and
subdirectories are named using device name.

So we'd then have /proc/net/dev_snmp6/{lo,eth0,eth1} etc.

Ok?
