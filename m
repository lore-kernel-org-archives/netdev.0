From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: remove local variable 'status'
Date: Wed, 18 Nov 2015 15:22:09 -0500 (EST)
Message-ID: <20151118.152209.326518985754435984.davem@davemloft.net>
References: <1447851994-12075-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sriharsha.basavapatna@avagotech.com,
	sathya.perla@avagotech.com, ajit.khaparde@avagotech.com,
	padmanabh.ratnakar@avagotech.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53461 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753515AbbKRUWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 15:22:11 -0500
In-Reply-To: <1447851994-12075-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Wed, 18 Nov 2015 14:06:34 +0100

> The lancer_cmd_get_file_len() uses lancer_cmd_read_object() to get
> the current size of registers for ethtool registers dump. Returned status
> value is stored but not checked. The check itself is not necessary as
> the data_read output variable is initialized to 0 and status variable
> can be removed.
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied.
