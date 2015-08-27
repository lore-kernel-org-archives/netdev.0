From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH v5 net-next 7/8] geneve: Consolidate Geneve functionality
 in single module.
Date: Thu, 27 Aug 2015 13:28:43 -0400
Message-ID: <20150827172843.GB8113@tuxdriver.com>
References: <1440658015-13028-1-git-send-email-pshelar@nicira.com>
 <1440658015-13028-8-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41989 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbbH0RaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 13:30:15 -0400
Content-Disposition: inline
In-Reply-To: <1440658015-13028-8-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 26, 2015 at 11:46:54PM -0700, Pravin B Shelar wrote:
> geneve_core module handles send and receive functionality.
> This way OVS could use the Geneve API. Now with use of
> tunnel meatadata mode OVS can directly use Geneve netdevice.
> So there is no need for separate module for Geneve. Following
> patch consolidates Geneve protocol processing in single module.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Acked-by: John W. Linville <linville@tuxdriver.com>

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
