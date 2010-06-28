From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH 4/9] cxgb4vf: Add code to provision T4 PCI-E SR-IOV Virtual Functions with hardware resources
Date: Mon, 28 Jun 2010 09:55:07 -0700
Message-ID: <201006280955.07352.leedom@chelsio.com>
References: <201006251511.46660.leedom@chelsio.com> <20100626133746.GB30133@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:17725 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752206Ab0F1QzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 12:55:08 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o5SGt8fA004934
	for <netdev@vger.kernel.org>; Mon, 28 Jun 2010 09:55:08 -0700
In-Reply-To: <20100626133746.GB30133@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| From: Simon Horman <horms@verge.net.au>
| Date: Saturday, June 26, 2010 06:37 am
| 
| I wonder if it would be cleaner to move the guts of the last hunk
| into a function (e.g. adap_init_sriov()) and have that be a dummy
| function in the case that CONFIG_PCI_IOV in the first hunk is not set.

  I have no objection to this.  I'd like to do minor tuning work like that as a 
follow on rather than respin the patch.  But, as I said in my submission, I'm 
not familiar with this process so if making changes like the above is required 
I'll definitely jump on it.  I don't know what issues are "critical show 
stoppers" and which ones are "nice to have" once things are in place.

  Thanks for your comments!

Casey
