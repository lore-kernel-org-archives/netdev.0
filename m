From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] act_connmark: avoid crashing on malformed nlattrs
 with null parms
Date: Sun, 12 Mar 2017 23:33:21 -0700 (PDT)
Message-ID: <20170312.233321.2181278921646612811.davem@davemloft.net>
References: <1489161332-5012-1-git-send-email-etienne.noss@wifirst.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, victorien.molle@wifirst.fr
To: etienne.noss@wifirst.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53826 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750943AbdCMGdW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 02:33:22 -0400
In-Reply-To: <1489161332-5012-1-git-send-email-etienne.noss@wifirst.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Etienne Noss <etienne.noss@wifirst.fr>
Date: Fri, 10 Mar 2017 16:55:32 +0100

> tcf_connmark_init does not check in its configuration if TCA_CONNMARK_PARMS
> is set, resulting in a null pointer dereference when trying to access it.
 ...
> Signed-off-by: Étienne Noss <etienne.noss@wifirst.fr>
> Signed-off-by: Victorien Molle <victorien.molle@wifirst.fr>

Applied and queued up for -stable, thanks.
