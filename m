From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] pf_packet updates
Date: Thu, 29 Aug 2013 01:39:38 -0400 (EDT)
Message-ID: <20130829.013938.2144325735677512661.davem@davemloft.net>
References: <1377720791-15844-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55005 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753246Ab3H2Fjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 01:39:40 -0400
In-Reply-To: <1377720791-15844-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Wed, 28 Aug 2013 22:13:08 +0200

> Daniel Borkmann (3):
>   net: packet: add random fanout scheduler
>   net: packet: use reciprocal_divide in fanout_demux_hash
>   net: packet: document available fanout policies

Please add the missing reciprocal_divide.h include to the second
patch, as per Eric Dumazet's feedback, and resubmit this series.

Thanks.
