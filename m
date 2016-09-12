From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v4 03/16] IB/pvrdma: Add virtual device RDMA structures
Date: Mon, 12 Sep 2016 11:50:29 -0600
Message-ID: <20160912175029.GF5843@obsidianresearch.com>
References: <1473655766-31628-1-git-send-email-aditr@vmware.com>
 <1473655766-31628-4-git-send-email-aditr@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        pv-drivers@vmware.com, netdev@vger.kernel.org,
        linux-pci@vger.kernel.org, jhansen@vmware.com, asarwade@vmware.com,
        georgezhang@vmware.com, bryantan@vmware.com
To: Adit Ranadive <aditr@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:49629 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751321AbcILRub (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Sep 2016 13:50:31 -0400
Content-Disposition: inline
In-Reply-To: <1473655766-31628-4-git-send-email-aditr@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 11, 2016 at 09:49:13PM -0700, Adit Ranadive wrote:
> +	__u8	raw[16];
> +	struct {
> +		__be64	subnet_prefix;
> +		__be64	interface_id;
> +	} global;

If this is not a userspace header do not use the __ varients..

Jason
