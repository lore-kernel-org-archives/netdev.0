From: Patrick McHardy <kaber@trash.net>
Subject: Re: macvlan: fix gso_max_size setting
Date: Mon, 23 Nov 2009 23:11:07 +0100
Message-ID: <4B0B087B.3020000@trash.net>
References: <4B0A64E2.8090203@trash.net> <20091123.101013.40629093.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52437 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756415AbZKWWLE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 17:11:04 -0500
In-Reply-To: <20091123.101013.40629093.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Mon, 23 Nov 2009 11:33:06 +0100
>
>   
>> Fix macvlan gso_max_size setting. Based on net-next-2.6.git.
>
> Pretty serious defect, maybe net-2.6 material?

Sure, please take it in net-2.6.
>
> If someone hits this, it's going to trigger something awful.

Don't drivers simply drop the packet? Otherwise I think you
should be able to trigger the same problem using the TC mirred
action.
