From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: don't age NTF_EXT_LEARNED fdb entries
Date: Tue, 28 Mar 2017 17:57:29 -0700 (PDT)
Message-ID: <20170328.175729.1177873512181660790.davem@davemloft.net>
References: <1490654801-10488-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39806 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932352AbdC2A5p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 20:57:45 -0400
In-Reply-To: <1490654801-10488-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Mon, 27 Mar 2017 15:46:41 -0700

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> vxlan driver already implicitly supports installing
> of external fdb entries with NTF_EXT_LEARNED. This
> patch just makes sure these entries are not aged
> by the vxlan driver. An external entity managing these
> entries will age them out. This is consistent with
> the use of NTF_EXT_LEARNED in the bridge driver.
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied, thank you.
