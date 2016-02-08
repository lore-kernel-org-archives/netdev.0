From: Jakub Kicinski <moorray3@wp.pl>
Subject: Re: [PATCH 2/2] fm10k: correctly report error when changing number
 of channels
Date: Mon, 8 Feb 2016 13:26:32 +0000
Message-ID: <20160208132632.3010dee3@jkicinski-Precision-T1700>
References: <1454704221-14238-1-git-send-email-jacob.e.keller@intel.com>
	<1454704221-14238-3-git-send-email-jacob.e.keller@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jacob Keller <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:18272 "EHLO mx4.wp.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751976AbcBHNdQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2016 08:33:16 -0500
In-Reply-To: <1454704221-14238-3-git-send-email-jacob.e.keller@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jacob!

First of all thanks for putting your time into sorting this out,
figuring out what to do with user-set RSS table when queues are
reconfigured was a head scratcher for me as well.

On Fri,  5 Feb 2016 12:30:21 -0800, Jacob Keller wrote:
> +#define FM10K_FLAG_RETA_TABLE_CONFIGURED	(u32)(BIT(6))

If we go with your proposal every driver will have to keep track of 
how the RSS table was set and find max value on queue reconfig -
replicating effort and leaving space for diverging behaviour...

Would it be worth considering to place more of this code in the core?
