From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] vxlan: don't flush static fdb entries on
 admin down
Date: Mon, 23 Jan 2017 16:07:41 -0500 (EST)
Message-ID: <20170123.160741.1558621534864494201.davem@davemloft.net>
References: <1484984599-16712-1-git-send-email-roopa@cumulusnetworks.com>
        <1484984599-16712-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ramanb@cumulusnetworks.com,
        stephen@networkplumber.org, jbenc@redhat.com, pshelar@ovn.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57720 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750705AbdAWVHn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 16:07:43 -0500
In-Reply-To: <1484984599-16712-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Fri, 20 Jan 2017 23:43:18 -0800

>  /* Purge the forwarding table */
> -static void vxlan_flush(struct vxlan_dev *vxlan)
> +static void vxlan_flush(struct vxlan_dev *vxlan, int do_all)

Please use 'bool' and true/false for this new argument.

FWIW, I am fine with changing the default behavior in this way.
