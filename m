From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next 0/3] re-org actor admin/oper key updates
Date: Mon, 02 Nov 2015 22:52:40 -0500 (EST)
Message-ID: <20151102.225240.1162453078430872461.davem@davemloft.net>
References: <1446320695-38570-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, andy@greyhouse.net, vfalico@gmail.com,
	nikolay@redhat.com, decot@google.com, netdev@vger.kernel.org
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39202 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751780AbbKCDwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 22:52:42 -0500
In-Reply-To: <1446320695-38570-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Sat, 31 Oct 2015 12:44:55 -0700

> I was observing machines entering into weird LACP state when the
> partner is in passive mode. This issue is not because of the partners
> in passive state but probably because of some operational key update
> which is pushing the state-machine is that weird state. This was
> happening randomly on about 1% of the machine (when the sample size
> is a large set of machines with a variety of NICs/ports bonded).
> 
> In this patch-series I'm attempting to unify the logic of actor-key
> / operational-key changes to one place to avoid possible errors in
> update. Also this eliminates the need for the event-handler to decide
> if the key needs update.
> 
> After this patch-set none of the machines (from same sample set) were
> exhibiting LACP-weirdness that was observed earlier.

Series applied, thanks.
