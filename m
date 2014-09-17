From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCHv5 net-next 0/3] sunvnet: add jumbo frames support
Date: Wed, 17 Sep 2014 18:33:24 -0400
Message-ID: <20140917223324.GK26828@oracle.com>
References: <5419F3DC.60104@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:50519 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757332AbaIQWda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 18:33:30 -0400
Content-Disposition: inline
In-Reply-To: <5419F3DC.60104@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
>  arch/sparc/include/asm/vio.h       |   44 ++++++++++-
>  arch/sparc/kernel/ldc.c            |    2 +-
>  arch/sparc/kernel/viohs.c          |   14 +++-
>  drivers/net/ethernet/sun/sunvnet.c |  146 +++++++++++++++++++++++++++++++-----
>  drivers/net/ethernet/sun/sunvnet.h |    7 ++-
>  5 files changed, 187 insertions(+), 26 deletions(-)
> 

A logistical question- this patch-set spans both sparc-next/sparclinux 
net-next/netdev, and there are obviously some dependancies here. 
What's the prescribed way to handle this sort of thing? 

(I ask, because I expect to soon be confronting a similar question with
some Rx side latency improvements that I'm working on, which will require
new functions for enabling/disabling interrupts in arch/sparc/kernel,
and I am wondering how that should get sequenced).

--Sowmini
