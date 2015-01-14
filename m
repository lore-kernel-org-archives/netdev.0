From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 0/5 net-next v4] VXLAN Group Policy Extension
Date: Wed, 14 Jan 2015 20:57:46 +0000
Message-ID: <20150114205746.GE2105@casper.infradead.org>
References: <cover.1421165078.git.tgraf@suug.ch>
 <20150114.153744.360580056667123059.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jesse@nicira.com, stephen@networkplumber.org, pshelar@nicira.com,
	therbert@google.com, alexei.starovoitov@gmail.com,
	nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	dev@openvswitch.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33293 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751792AbbANU5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 15:57:48 -0500
Content-Disposition: inline
In-Reply-To: <20150114.153744.360580056667123059.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/15 at 03:37pm, David Miller wrote:
> From: Thomas Graf <tgraf@suug.ch>
> Date: Tue, 13 Jan 2015 17:20:41 +0100
> 
> > Implements supports for the Group Policy VXLAN extension [0] to provide
> > a lightweight and simple security label mechanism across network peers
> > based on VXLAN. The security context and associated metadata is mapped
> > to/from skb->mark. This allows further mapping to a SELinux context
> > using SECMARK, to implement ACLs directly with nftables, iptables, OVS,
> > tc, etc.
> > 
> > The extension is disabled by default and should be run on a distinct
> > port in mixed Linux VXLAN VTEP environments. Liberal VXLAN VTEPs
> > which ignore unknown reserved bits will be able to receive VXLAN-GBP
> > frames.
> 
> Thomas, unfortunately Tom's vxlan RCO patches were ready before your's
> in my queue so I applied his work first.  You'll have to therefore
> respin this series on top of it.

Sure, no problem.
