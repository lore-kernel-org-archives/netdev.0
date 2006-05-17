From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: skge driver oops
Date: Wed, 17 May 2006 12:17:23 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0605171215360.5710@bizon.gios.gov.pl>
References: <BB1F4EFD574E9F409035BDA71C961250024195@exchange.i-bn>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org,
	"'Stephen Hemminger'" <shemminger@osdl.org>,
	"'david@mantara.com'" <david@mantara.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:41683 "EHLO
	bizon.gios.gov.pl") by vger.kernel.org with ESMTP id S1750857AbWEQKRn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 May 2006 06:17:43 -0400
To: Beschorner Daniel <Daniel.Beschorner@facton.com>
In-Reply-To: <BB1F4EFD574E9F409035BDA71C961250024195@exchange.i-bn>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 17 May 2006, Beschorner Daniel wrote:

> As David and me are using SMP systems when it's crashing, should I give a
> non-SMP kernel a try, to see if it's some kind of race conditon?

You may also try this, where ethX is your skge driven ethernet device:
   /usr/sbin/ethtool -K ethX tx off

This solved my simmilar problem.

Best regards,

 			Krzysztof Oledzki
