From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] Virtual ethernet device (tunnel)
Date: Wed, 2 May 2007 09:37:02 -0700
Message-ID: <20070502093702.3a076140@localhost.localdomain>
References: <46386DFB.7090109@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Ben Greear <greearb@candelatech.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>,
	Kirill Korotaev <dev@sw.ru>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, devel@openvz.org
To: Pavel Emelianov <xemul@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:38223 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2993514AbXEBQnk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 12:43:40 -0400
In-Reply-To: <46386DFB.7090109@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 02 May 2007 14:54:51 +0400
Pavel Emelianov <xemul@sw.ru> wrote:

> Veth stands for Virtual ETHernet. It is a simple tunnel driver
> that works at the link layer and looks like a pair of ethernet
> devices interconnected with each other.
> 
> Mainly it allows to communicate between network namespaces but
> it can be used as is as well.
> 
> Eric recently sent a similar driver called etun. This
> implementation is closer to the OpenVZ one and it lacks
> some unimportant features of etun driver (like ethtool_ops)
> for simplicity.

The ethtool stuff lets bonding and bridging work better.
