From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH 0/2] Netns performance improvements
Date: Tue, 5 Jul 2016 16:49:20 +0200
Message-ID: <20160705144920.GD620@orbyte.nwl.cc>
References: <1467729773-16751-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W . Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:34438 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932953AbcGEOtV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2016 10:49:21 -0400
Content-Disposition: inline
In-Reply-To: <1467729773-16751-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Jul 05, 2016 at 04:42:51PM +0200, Phil Sutter wrote:
> Stress-testing OpenStack Neutron revealed poor performance of 'ip netns'
> when dealing with a high amount of namespaces. The cause of this lies in
> the combination of how iproute2 mounts NETNS_RUN_DIR and the netns files
> therein and the fact that systemd makes all mount points of the system
> shared.
> 
> Phil Sutter (2):
>   ipnetns: Move NETNS_RUN_DIR into it's own propagation group
>   ipnetns: Make netns mount points private

Please disregard this series for now, I forgot to give credit to the
original author of the changeset.

Sorry for the noise!

Phil
