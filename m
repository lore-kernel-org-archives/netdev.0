From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cirrus: Remove redundant NULL check before kfree
Date: Tue, 26 Feb 2013 17:20:20 -0500 (EST)
Message-ID: <20130226.172020.294726073755354721.davem@davemloft.net>
References: <1361908173-3157-1-git-send-email-s.syam@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hsweeten@visionengravers.com
To: syamsidhardh@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43191 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753029Ab3BZWUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 17:20:22 -0500
In-Reply-To: <1361908173-3157-1-git-send-email-s.syam@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


All of these NULL check removals are not bug fixes, and therefore
not appropriate for the 'net' tree.  They should be targetted at
'net-next' which is closed at this time.

Please resubmit your patches when I announce on netdev that 'net-next'
is open for submissions once more.

Thanks.
