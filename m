From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netxen: fix link notification order
Date: Thu, 12 Jul 2012 07:57:13 -0700 (PDT)
Message-ID: <20120712.075713.188581964445128482.davem@davemloft.net>
References: <1342033015-31442-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	rajesh.borundia@qlogic.com
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57273 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932528Ab2GLO5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 10:57:14 -0400
In-Reply-To: <1342033015-31442-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>
Date: Wed, 11 Jul 2012 15:56:55 -0300

> First update the adapter variables with the current speed and
> mode before fire the notification. Otherwise, the get_settings()
> may provide old values.
> 
> Signed-off-by: Flavio Leitner <fbl@redhat.com>

Applied.
