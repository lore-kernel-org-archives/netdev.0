From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 1/8] i40e: main driver core
Date: Tue, 27 Aug 2013 21:31:26 -0400 (EDT)
Message-ID: <20130827.213126.55332679876689993.davem@davemloft.net>
References: <20130823.002805.1975660490102085087.davem@davemloft.net>
	<FC41C24E35F18A40888AACA1A36F3E416C615C3B@FMSMSX102.amr.corp.intel.com>
	<FC41C24E35F18A40888AACA1A36F3E416C617400@FMSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	gospo@redhat.com, sassmann@redhat.com
To: shannon.nelson@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35666 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752430Ab3H1Bba (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 21:31:30 -0400
In-Reply-To: <FC41C24E35F18A40888AACA1A36F3E416C617400@FMSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Nelson, Shannon" <shannon.nelson@intel.com>
Date: Tue, 27 Aug 2013 20:34:04 +0000

> I understand the aesthetics as it does make the code look a little
> cleaner, and we can do this with a lot of our functions.  However,
> there are several instances where one declaration initialization
> depends on a previous declaration, and trying to organize by line
> length breaks these relationships.  Do you mind if we're not perfect
> on following this one?

Put the assignments that can match the ordering rule into the
declarations, put the remaining ones on seperate lines after
the declarations.
