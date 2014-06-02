From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] team: fix mtu setting
Date: Mon, 02 Jun 2014 14:56:44 -0700 (PDT)
Message-ID: <20140602.145644.1523465834170343329.davem@davemloft.net>
References: <1401389177-10463-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fbl@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37113 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbaFBV4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 17:56:48 -0400
In-Reply-To: <1401389177-10463-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 29 May 2014 20:46:17 +0200

> Now it is not possible to set mtu to team device which has a port
> enslaved to it. The reason is that when team_change_mtu() calls
> dev_set_mtu() for port device, notificator for NETDEV_PRECHANGEMTU
> event is called and team_device_event() returns NOTIFY_BAD forbidding
> the change. So fix this by returning NOTIFY_DONE here in case team is
> changing mtu in team_change_mtu().
> 
> Introduced-by: 3d249d4c "net: introduce ethernet teaming device"
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied and queued up for -stable, thanks.
