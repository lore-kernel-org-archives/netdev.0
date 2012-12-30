From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] team: add ethtool support
Date: Sat, 29 Dec 2012 18:09:30 -0800 (PST)
Message-ID: <20121229.180930.2054437059250829691.davem@davemloft.net>
References: <1356830366-991-1-git-send-email-fbl@redhat.com>
	<20121229172945.25a09fc8@nehalam.linuxnetplumber.net>
	<20121230014403.GA2077@obelix.rh>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, jiri@resnulli.us
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37033 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753881Ab2L3CJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2012 21:09:33 -0500
In-Reply-To: <20121230014403.GA2077@obelix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>
Date: Sat, 29 Dec 2012 23:44:03 -0200

> Right, but those statistics can be device specific as well.  The tg3 and bnx2, for
> instance, do the same reporting [rx|tx]_bytes|octets. 

Because those ARE PER QUEUE in multiqueue configurations, and thus
device specific.

There is no reason to report the bare single-queue generic
netdevice stats via ethtool.
