From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: sctp: minor: make jsctp_sf_eat_sack
 static
Date: Wed, 13 Feb 2013 14:04:36 -0500 (EST)
Message-ID: <20130213.140436.521031425285650154.davem@davemloft.net>
References: <cover.1360752304.git.dborkman@redhat.com>
	<7eef4b701794c1bb78819bc6e6c45bf99b49801d.1360752304.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43190 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758662Ab3BMTEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 14:04:38 -0500
In-Reply-To: <7eef4b701794c1bb78819bc6e6c45bf99b49801d.1360752304.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Wed, 13 Feb 2013 12:03:49 +0100

> The function jsctp_sf_eat_sack can be made static, no need to extend
> its visibility.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

It's exported for the jprobe lookup by ->symbol_name

Did you test this?
