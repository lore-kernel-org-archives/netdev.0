From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gro: relax ID check in inet_gro_receive()
Date: Thu, 21 Mar 2013 12:31:54 -0400 (EDT)
Message-ID: <20130321.123154.1097765138288338335.davem@davemloft.net>
References: <1363841553.3333.47.camel@edumazet-glaptop>
	<20130321.114616.279859400813363663.davem@davemloft.net>
	<1363882091.4431.20.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dmitry@broadcom.com, eilong@broadcom.com,
	pshelar@nicira.com, hkchu@google.com, maze@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44076 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932371Ab3CUQb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 12:31:56 -0400
In-Reply-To: <1363882091.4431.20.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 21 Mar 2013 09:08:11 -0700

> I understand your concern, but this check in GRO brings nothing at all.

It brings reversibility, a fundamental rule of our segmentation
offloads.
