From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] datapath: Rename last_action() as
 nla_is_last() and move to netlink.h
Date: Tue, 28 Oct 2014 17:08:08 -0400 (EDT)
Message-ID: <20141028.170808.1107344256534933398.davem@davemloft.net>
References: <1414393936-14463-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com, dev@openvswitch.org,
	tgraf@suug.ch, azhou@nicira.com
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36011 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400AbaJ1VIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 17:08:11 -0400
In-Reply-To: <1414393936-14463-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Mon, 27 Oct 2014 16:12:16 +0900

> The original motivation for this change was to allow the helper to be used
> in files other than actions.c as part of work on an odp select group
> action.
> 
> It was as pointed out by Thomas Graf that this helper would be best off
> living in netlink.h. Furthermore, I think that the generic nature of this
> helper means it is best off in netlink.h regardless of if it is used more
> than one .c file or not. Thus, I would like it considered independent of
> the work on an odp select group action.
> 
> Cc: Thomas Graf <tgraf@suug.ch>
> Cc: Pravin Shelar <pshelar@nicira.com>
> Cc: Andy Zhou <azhou@nicira.com>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

Applied, thanks Simon.
