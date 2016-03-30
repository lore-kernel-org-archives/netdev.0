From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [net PATCH] i40e/i40evf: Limit TSO to 7 descriptors for payload
 instead of 8 per packet
Date: Wed, 30 Mar 2016 13:00:11 -0400
Message-ID: <20160330170011.GB27540@oracle.com>
References: <20160330064213.12927.46852.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	jesse.brandeburg@intel.com, alexander.duyck@gmail.com,
	jeffrey.t.kirsher@intel.com
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:48636 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755028AbcC3RAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 13:00:25 -0400
Content-Disposition: inline
In-Reply-To: <20160330064213.12927.46852.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (03/29/16 23:44), Alexander Duyck wrote:
> This patch has been sanity checked only.  I cannot yet guarantee it
> resolves the original issue that was reported.  I'll try to get a
> reproduction environment setup tomorrow but I don't know how long that
> should take.

I tried this out with rds-stress on my test-pair, unfortunately, I
still see the Tx hang.

Setting up the test is quite easy- for reference, the instructions 
are here:
   https://sourceforge.net/p/e1000/mailman/message/34936766/

--Sowmini
