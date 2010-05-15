From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next-2.6 V8 PATCH 0/2] Add virtual port netlink support
Date: Fri, 14 May 2010 18:29:57 -0700
Message-ID: <20100514182957.4998bea4@nehalam>
References: <20100515010415.21260.35219.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, chrisw@redhat.com,
	arnd@arndb.de, kaber@trash.net
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51719 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751800Ab0EOBaA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 May 2010 21:30:00 -0400
In-Reply-To: <20100515010415.21260.35219.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 May 2010 18:04:23 -0700
Scott Feldman <scofeldm@cisco.com> wrote:

> [Add symmetrical set/get layout per Patrick McHardy suggestions]
> 
> The following series adds virtual port netlink support and adds an
> implementation to Cisco's enic netdev driver:
> 
> 	1/2: Adds virtual netlink RTM_SETLINK/RTM_GETLINK support, and
> 	     adds matching netdev ops net_{set|get}_vf_port.
> 
> 	2/2: Adds enic support for net_{set|get}_vf_port for enic
> 	     dynamic devices.
> 
> Signed-off-by: Scott Feldman <scofeldm@cisco.com>
> Signed-off-by: Roopa Prabhu<roprabhu@cisco.com>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

I assume there will be some documentation for this when the patch
to iproute for supporting this comes out.
