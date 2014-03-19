From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 01/15] i40e: support VF link state ndo
Date: Wed, 19 Mar 2014 14:06:09 -0400 (EDT)
Message-ID: <20140319.140609.2180508884816449731.davem@davemloft.net>
References: <1395200533-16908-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1395200533-16908-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mitch.a.williams@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, catherine.sullivan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37138 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812AbaCSSGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 14:06:11 -0400
In-Reply-To: <1395200533-16908-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 18 Mar 2014 20:41:59 -0700

> +	vf = &(pf->vf[vf_id]);

These parenthesis are unnecessary, and in fact confusing.  Someone reading
this is going to look again and again trying to figure out why they are
needed.
