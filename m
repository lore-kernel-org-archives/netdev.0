From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pch_gbe: minor: report the actual error on
 MTU change
Date: Tue, 16 Apr 2013 16:39:04 -0400 (EDT)
Message-ID: <20130416.163904.984215021672555885.davem@davemloft.net>
References: <1366126092-22683-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tshimizu818@gmail.com,
	richardcochran@gmail.com, andy.cress@us.kontron.com
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49749 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965164Ab3DPUjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 16:39:06 -0400
In-Reply-To: <1366126092-22683-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Tue, 16 Apr 2013 17:28:12 +0200

> If we can't _up() after changing the MTU, report the actual error instead
> of -ENOMEM. It can be really misleading cause pch_gbe is usually used in
> scenarios where the memory amount is really small, and thus hiding the
> real cause.
> 
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Applied.
