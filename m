From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v4 5/5] ipv6: Add generic UDP Tunnel
 segmentation
Date: Fri, 19 Apr 2013 19:30:56 +0800
Message-ID: <1366371056.5117.3.camel@cr0>
References: <1366175423-27310-1-git-send-email-amwang@redhat.com>
	 <1366175423-27310-6-git-send-email-amwang@redhat.com>
	 <CALnjE+peRJga4HK7v9e-1v1F0xftNkejd9O5KngVRuu2P2VtQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15082 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968066Ab3DSLbP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 07:31:15 -0400
In-Reply-To: <CALnjE+peRJga4HK7v9e-1v1F0xftNkejd9O5KngVRuu2P2VtQw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-18 at 10:23 -0700, Pravin Shelar wrote:
> skb_udp6_tunnel_segment() looks alot like skb_udp_tunnel_segment(),
> difference is checksum calculation. I think we can write a common
> function here. 

Agreed, will try.
