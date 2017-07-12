From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] nfp: freeing the wrong variable
Date: Wed, 12 Jul 2017 08:19:02 -0700 (PDT)
Message-ID: <20170712.081902.1365961724075582090.davem@davemloft.net>
References: <20170712074206.otviyjx2qhuz3snt@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, pieter.jansenvanvuuren@netronome.com,
        simon.horman@netronome.com, oss-drivers@netronome.com,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55302 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752617AbdGLPTD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2017 11:19:03 -0400
In-Reply-To: <20170712074206.otviyjx2qhuz3snt@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 12 Jul 2017 10:42:06 +0300

> We accidentally free a NULL pointer and leak the pointer we want to
> free.  Also you can tell from the label name what was intended.  :)
> 
> Fixes: abfcdc1de9bf ("nfp: add a stats handler for flower offloads")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
