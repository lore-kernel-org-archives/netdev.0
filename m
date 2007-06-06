From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 06 Jun 2007 19:35:46 -0400
Message-ID: <1181172946.4064.87.camel@localhost>
References: <1181168020.4064.46.camel@localhost>
	 <D5C1322C3E673F459512FB59E0DDC32902FC61BF@orsmsx414.amr.corp.intel.com>
	 <20070606.154041.08321169.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, kaber@trash.net,
	netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.231]:24144 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965005AbXFFXft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 19:35:49 -0400
Received: by nz-out-0506.google.com with SMTP id n1so328279nzf
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2007 16:35:48 -0700 (PDT)
In-Reply-To: <20070606.154041.08321169.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-06-06 at 15:40 -0700, David Miller wrote:


> There are two core issues in my mind:
> 
> 1) multi-queue on both RX and TX is going to be very pervasive very
>    soon, everyone is putting this into silicon.
> 
>    The parallelization gain potential is enormous, and we have to
>    design for this.
> 

There is no potential for parallelizing on transmit that i can think of.
Dave, please explain it slowly so i can understand it.

There is huge potential for parallelizing on receive. But i am certainly
missing the value in the transmit.

cheers,
jamal


