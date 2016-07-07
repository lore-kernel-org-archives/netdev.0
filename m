From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCHv2 0/2] Netns performance improvements
Date: Wed, 6 Jul 2016 21:22:57 -0700
Message-ID: <20160706212257.4e35d0fb@xeon-e3>
References: <1467730280-17493-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemming@brocade.com>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36691 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720AbcGGEWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 00:22:48 -0400
Received: by mail-pa0-f54.google.com with SMTP id uj8so2544458pab.3
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 21:22:48 -0700 (PDT)
In-Reply-To: <1467730280-17493-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  5 Jul 2016 16:51:18 +0200
Phil Sutter <phil@nwl.cc> wrote:

> Stress-testing OpenStack Neutron revealed poor performance of 'ip netns'
> when dealing with a high amount of namespaces. The cause of this lies in
> the combination of how iproute2 mounts NETNS_RUN_DIR and the netns files
> therein and the fact that systemd makes all mount points of the system
> shared.
> 
> Changes since v1:
> - Added Suggested-by tag to patches.
> 
> Phil Sutter (2):
>   ipnetns: Move NETNS_RUN_DIR into it's own propagation group
>   ipnetns: Make netns mount points private
> 
>  ip/ipnetns.c | 12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)
> 

I want an ack for Eric on this, it seems a little risky
