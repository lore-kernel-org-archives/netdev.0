From: Thomas Graf <tgraf@noironetworks.com>
Subject: Re: [ovs-dev] [PATCH net-next] datapath: Rename last_action() as
 nla_is_last() and move to netlink.h
Date: Mon, 27 Oct 2014 11:08:26 +0100
Message-ID: <20141027100826.GA25339@pox.localdomain>
References: <1414393936-14463-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Pravin Shelar <pshelar@nicira.com>, dev@openvswitch.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:33255 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785AbaJ0KI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2014 06:08:29 -0400
Received: by mail-wg0-f41.google.com with SMTP id b13so5238644wgh.0
        for <netdev@vger.kernel.org>; Mon, 27 Oct 2014 03:08:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1414393936-14463-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/14 at 04:12pm, Simon Horman wrote:
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

Acked-by: Thomas Graf <tgraf@noironetworks.com>
