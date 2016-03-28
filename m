From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] team: team should sync the port's uc/mc addrs when
 add a port
Date: Mon, 28 Mar 2016 20:04:25 +0200
Message-ID: <20160328180425.GA2070@nanopsycho.orion>
References: <320fc71dbbf5ed164ca506cf5750b7bf4e048d44.1459183351.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, davem@davemloft.net,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:33724 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004AbcC1SE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 14:04:29 -0400
Received: by mail-wm0-f46.google.com with SMTP id r72so26218818wmg.0
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 11:04:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <320fc71dbbf5ed164ca506cf5750b7bf4e048d44.1459183351.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 28, 2016 at 06:42:31PM CEST, lucien.xin@gmail.com wrote:
>There is an issue when we use mavtap over team:
>When we replug nic links from team0, the real nics's mc list will not
>include the maddr for macvtap any more. then we can't receive pkts to
>macvtap device, as they are filterred by mc list of nic.
>
>In Bonding Driver, it syncs the uc/mc addrs in bond_enslave().
>
>We will fix this issue on team by adding the port's uc/mc addrs sync in
>team_port_add.
>
>Signed-off-by: Xin Long <lucien.xin@gmail.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
