From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Prefix List against 2.5.70 (re-done)
Date: Wed, 25 Jun 2003 23:42:51 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030625.234251.116353369.davem@redhat.com>
References: <3EF37458.3070103@us.ibm.com>
	<20030621.233634.67057417.yoshfuji@linux-ipv6.org>
	<3EF9D5C2.5080101@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: krkumar@us.ibm.com
In-Reply-To: <3EF9D5C2.5080101@us.ibm.com>
List-Id: netdev.vger.kernel.org


I don't think it's wise to make RTNETLINK facilities
dependant upon ifdef values.

Please kill CONFIG_IPV6_PREFIXLIST.  People don't need to
to enable funny options to get a fully function dhcp on
ipv4, they should therefore not have to for ipv6 either.
