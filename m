From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next] datapath: Rename last_action() as nla_is_last()
 and move to netlink.h
Date: Wed, 29 Oct 2014 11:10:17 +0900
Message-ID: <20141029021014.GA668@vergenet.net>
References: <1414393936-14463-1-git-send-email-simon.horman@netronome.com>
 <20141028.170808.1107344256534933398.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pshelar@nicira.com, dev@openvswitch.org,
	tgraf@suug.ch, azhou@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:44814 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515AbaJ2CK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 22:10:28 -0400
Received: by mail-pa0-f43.google.com with SMTP id eu11so2086528pac.30
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2014 19:10:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20141028.170808.1107344256534933398.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 28, 2014 at 05:08:08PM -0400, David Miller wrote:
> From: Simon Horman <simon.horman@netronome.com>
> Date: Mon, 27 Oct 2014 16:12:16 +0900
> 
> > The original motivation for this change was to allow the helper to be used
> > in files other than actions.c as part of work on an odp select group
> > action.
> > 
> > It was as pointed out by Thomas Graf that this helper would be best off
> > living in netlink.h. Furthermore, I think that the generic nature of this
> > helper means it is best off in netlink.h regardless of if it is used more
> > than one .c file or not. Thus, I would like it considered independent of
> > the work on an odp select group action.
> > 
> > Cc: Thomas Graf <tgraf@suug.ch>
> > Cc: Pravin Shelar <pshelar@nicira.com>
> > Cc: Andy Zhou <azhou@nicira.com>
> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
> 
> Applied, thanks Simon.

Thanks
