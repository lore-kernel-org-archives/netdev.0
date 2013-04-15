From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] team: Use new sync_multiple api to sync devices
 adressess.
Date: Mon, 15 Apr 2013 15:45:39 -0400 (EDT)
Message-ID: <20130415.154539.1016433031972939376.davem@davemloft.net>
References: <1366052997-12435-1-git-send-email-vyasevic@redhat.com>
	<1366052997-12435-3-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35754 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753366Ab3DOTpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 15:45:41 -0400
In-Reply-To: <1366052997-12435-3-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Mon, 15 Apr 2013 15:09:57 -0400

> Team drivers attempts to sync addresses to each of of the port
                                                  ^^^^^

Maybe you meant only one "of" here.

> devices; however, the current api doesn't do anything for anything
> after the first device.  Switch to using the new api that will
> actually sync the addresses to all ports.

"anything for anything" sounds awkward, perhaps "anything for devices
on the list after the first device" or something like that.

Thanks.
