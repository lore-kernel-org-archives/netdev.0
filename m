From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH nf-next v10 7/8] openvswitch: Delay conntrack helper call
 for new connections.
Date: Fri, 11 Mar 2016 11:01:33 +1300
Message-ID: <CAPWQB7Hshep+Uy482hiX5UYF67Zd4OXVCgUsC08TA_78JghoZg@mail.gmail.com>
References: <1457636063-92746-1-git-send-email-jarno@ovn.org> <1457636063-92746-8-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:54722 "EHLO
	relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932591AbcCJWB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 17:01:56 -0500
In-Reply-To: <1457636063-92746-8-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11 March 2016 at 07:54, Jarno Rajahalme <jarno@ovn.org> wrote:
> There is no need to help connections that are not confirmed, so we can
> delay helping new connections to the time when they are confirmed.
> This change is needed for NAT support, and having this as a separate
> patch will make the following NAT patch a bit easier to review.
>
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>

Acked-by: Joe Stringer <joe@ovn.org>
