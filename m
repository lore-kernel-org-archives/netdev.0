From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: Re: [patch 0/6] netfilter: ctnetlink allocation improvement
Date: Tue, 17 Mar 2009 08:39:26 +0100
Message-ID: <20090317073926.GA1030@mail.eitzenberger.org>
References: <20090316220659.756862181@jonathan.eitzenberger.org> <49BF28A3.3010606@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:61528 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756972AbZCQKpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 06:45:11 -0400
Content-Disposition: inline
In-Reply-To: <49BF28A3.3010606@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 17, 2009 at 05:35:47AM +0100, Patrick McHardy wrote:

> Its preferrable not to use module reference counting during packet
> processing, the protocols can be accessed safely using RCU. I thought
> I had fixed all those areas, but I now notice that ctnetlink is full
> of similar spots and takes and drops module references quite
> excessively. So just leave it as it is I guess, this should be fully
> fixed anyways.

Thanks Patrick.

