From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cisco: enic: Fic an error handling path in
 'vnic_dev_init_devcmd2()'
Date: Tue, 11 Jul 2017 10:54:32 -0700 (PDT)
Message-ID: <20170711.105432.2013597475678597815.davem@davemloft.net>
References: <20170708045135.14753-1-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benve@cisco.com, govind@gmx.com, neepatel@cisco.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: christophe.jaillet@wanadoo.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39290 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755866AbdGKRyj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2017 13:54:39 -0400
In-Reply-To: <20170708045135.14753-1-christophe.jaillet@wanadoo.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Date: Sat,  8 Jul 2017 06:51:35 +0200

> if 'ioread32()' returns 0xFFFFFFF, we have to go through the error
> handling path as done everywhere else in this function.
> 
> Move the 'err_free_wq' label to better match its name and its location
> and add a new label 'err_disable_wq'.
> Update the code accordingly.
> 
> Fixes: 373fb0873d43 ("enic: add devcmd2")
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

Looks good, applied, thanks.
