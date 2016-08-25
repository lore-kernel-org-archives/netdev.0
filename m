From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next 1/2] cxgb4/cxgb4vf: Add support for
 ndo_set_vf_vlan
Date: Thu, 25 Aug 2016 16:24:05 -0700 (PDT)
Message-ID: <20160825.162405.408460591169068270.davem@redhat.com>
References: <1472021434-8287-1-git-send-email-hariprasad@chelsio.com>
        <1472021434-8287-2-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48452 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757879AbcHYXsH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 19:48:07 -0400
In-Reply-To: <1472021434-8287-2-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Wed, 24 Aug 2016 12:20:33 +0530

> +	dev_info(pi->adapter->pdev_dev,
> +		 "Setting Vlan %u to VF [%d]\n", vlan, vf);
> +	dev_info(pi->adapter->pdev_dev,
> +		 "The VF [%d] interface needs to brought down and up, "
> +		 "if VF is already up and running, for VST to work\n", vf);

Requiring the user to do something like this for the feature to work
correctly is not reasonable at all.

I want you to seriously consider rearchitecting this whole facility.
