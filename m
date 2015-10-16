From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] drivers/net: get rid of unnecessary
 initializations in .get_drvinfo()
Date: Fri, 16 Oct 2015 00:24:28 -0700 (PDT)
Message-ID: <20151016.002428.1307280478503508475.davem@davemloft.net>
References: <1444937332-26848-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51631 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753061AbbJPHIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 03:08:19 -0400
In-Reply-To: <1444937332-26848-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Thu, 15 Oct 2015 21:28:52 +0200

> Many drivers initialize uselessly n_priv_flags, n_stats, testinfo_len,
> eedump_len & regdump_len fields in their .get_drvinfo() ethtool op.
> It's not necessary as these fields is filled in ethtool_get_drvinfo().
> 
> v2: removed unused variable
> v3: removed another unused variable
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied, thanks.
