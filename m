From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] packet: support for TX time stamps on RAW sockets
Date: Wed, 07 Apr 2010 21:47:59 -0700 (PDT)
Message-ID: <20100407.214759.127673581.davem@davemloft.net>
References: <20100406143030.GA26954@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, patrick.ohly@intel.com
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45222
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750830Ab0DHEr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 00:47:56 -0400
In-Reply-To: <20100406143030.GA26954@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Tue, 6 Apr 2010 16:30:30 +0200

> Enable the SO_TIMESTAMPING socket infrastructure for raw packet sockets.
> For lack of a better idea, we have elected to use PACKET_RECV_OUTPUT for
> the control message cmsg_type. This macro currently is not used anywhere
> within the kernel.
> 
> Similar support for UDP and CAN sockets was added in commit
> 51f31cabe3ce5345b51e4a4f82138b38c4d5dc91
> 
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>

Why not add some new value, with a well formed name, just to make it
explicit what it's used for?


> +	put_cmsg(msg,SOL_PACKET,PACKET_RECV_OUTPUT,sizeof(serr->ee),&serr->ee);

Spaces between arguments, and you'll thus need to break this up into
multiple lines to keep it within 80 columns.
