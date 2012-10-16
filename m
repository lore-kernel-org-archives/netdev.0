From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] vlan: fix bond/team enslave of vlan challenged
 slave/port
Date: Tue, 16 Oct 2012 14:56:33 -0400 (EDT)
Message-ID: <20121016.145633.880276724748013235.davem@davemloft.net>
References: <1350225056-14144-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	kaber@trash.net, jstanley@rmrf.net
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60818 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755681Ab2JPS4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 14:56:35 -0400
In-Reply-To: <1350225056-14144-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sun, 14 Oct 2012 16:30:56 +0200

> In vlan_uses_dev() check for number of vlan devs rather than existence
> of vlan_info. The reason is that vlan id 0 is there without appropriate
> vlan dev on it by default which prevented from enslaving vlan challenged
> dev.
> 
> Reported-by: Jon Stanley <jstanley@rmrf.net>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied and queued up for -stable, thanks.
