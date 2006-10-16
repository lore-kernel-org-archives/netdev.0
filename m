From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 7366] New: BUG: unable to handle kernel paging
 request at virtual address d0cb03e0
Date: Mon, 16 Oct 2006 07:41:39 +0200
Message-ID: <45331B93.7000006@trash.net>
References: <200610152100.k9FL0XCW014322@fire-2.osdl.org> <20061015220952.08dde7b3.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60575 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751473AbWJPFlt
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Oct 2006 01:41:49 -0400
To: cristi@itz.ro
In-Reply-To: <20061015220952.08dde7b3.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> 
>>http://bugzilla.kernel.org/show_bug.cgi?id=7366
>>_______________________________
>>Oct 15 17:38:40 test kernel: BUG: unable to handle kernel paging request at
>>virtual address d0cb03e0
>>Oct 15 17:38:40 test kernel:  printing eip:
>>Oct 15 17:38:40 test kernel: d08fc19b
>>Oct 15 17:38:40 test kernel: *pde = 0ba03067
>>Oct 15 17:38:40 test kernel: *pte = 00000000
>>Oct 15 17:38:40 test kernel: Oops: 0000 [#1]
>>Oct 15 17:38:40 test kernel: SMP
>>Oct 15 17:38:40 test kernel: Modules linked in: ipt_MASQUERADE iptable_nat
>>ip_nat ip_conntrack xt_limit ip6table_filter ip6_tables xt_mac xt_tcpudp
>>xt_pkttype iptable_raw xt_CLASSIFY xt_MARK xt_length xt_physdev bridge xt_policy
>>xt_multiport ipt_ULOG ipt_TTL ipt_ttl ipt_TOS ipt_tos ipt_TCPMSS ipt_REJECT
>>ipt_recent ipt_owner ipt_LOG ipt_iprange ipt_ipp2p ipt_hashlimit ipt_ECN ipt_ecn
>>ipt_CLUSTERIP ipt_ah ipt_addrtype nfnetlink iptable_mangle nfsd exportfs lockd
>>nfs_acl ipv6 sunrpc iptable_filter ip_tables x_tables i810_audio ac97_codec
>>soundcore 8139too mii af_packet ide_cd binfmt_misc loop dm_mod video thermal sbs
>>processor i2c_ec i2c_core fan container button battery asus_acpi ac intel_agp
>>agpgart uhci_hcd usbcore ext3 jbd


Does it also happen without external patches like ipp2p? Did you
load/unload any netfilter modules before?

