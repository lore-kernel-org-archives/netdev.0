From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net: get rid of unnecessary
 initializations in .get_drvinfo()
Date: Wed, 14 Oct 2015 19:26:44 -0700 (PDT)
Message-ID: <20151014.192644.1811314692228642214.davem@davemloft.net>
References: <1444840072-21313-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bwh@kernel.org
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38424 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753742AbbJOCKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 22:10:39 -0400
In-Reply-To: <1444840072-21313-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Wed, 14 Oct 2015 18:27:52 +0200

> Many drivers initialize uselessly n_priv_flags, n_stats, testinfo_len,
> eedump_len & regdump_len fields in their .get_drvinfo() ethtool op.
> It's not necessary as these fields is filled in ethtool_get_drvinfo().
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
 ...
>  drivers/net/usb/sr9800.c                                | 1 -

Please fix this unused variable warning added to this file and
resubmit, thanks.
