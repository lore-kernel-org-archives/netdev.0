From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH Iproute2 next] ip link: Add ipvlan support to the
 iproute2/ip util
Date: Fri, 14 Nov 2014 11:09:59 +0100
Message-ID: <20141114100959.GA19965@unicorn.suse.cz>
References: <1415948212-28927-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	Laurent Chavey <chavey@google.com>,
	Tim Hockin <thockin@google.com>,
	David Miller <davem@davemloft.net>,
	Brandon Philips <brandon.philips@coreos.com>,
	Pavel Emelianov <xemul@parallels.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:56454 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754899AbaKNKKD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2014 05:10:03 -0500
Content-Disposition: inline
In-Reply-To: <1415948212-28927-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 13, 2014 at 10:56:51PM -0800, Mahesh Bandewar wrote:
> Adding basic support to create virtual devices using 'ip'
> utility. Following is the syntax -
> 
> 	ip link add link <master> <virtual> mode [ l2 | l3 ]
> 	e.g. ip link add link eth0 ipvl0 mode l3

I suppose "type ipvlan" is missing on both lines.

Michal Kubecek
