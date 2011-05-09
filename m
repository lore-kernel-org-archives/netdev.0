From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: Fixed bugs related to PVID.
Date: Mon, 09 May 2011 11:51:24 -0700 (PDT)
Message-ID: <20110509.115124.183055796.davem@davemloft.net>
References: <fe5f0791-266c-4fd7-9bfb-302b144c8a66@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: somnath.kotur@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44781
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753445Ab1EISv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 14:51:56 -0400
In-Reply-To: <fe5f0791-266c-4fd7-9bfb-302b144c8a66@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>
Date: Thu, 5 May 2011 14:10:46 +0530

> Fixed bug to make sure 'pvid' retrieval will work on big endian hosts.
> Fixed incorrect comparison between the Rx Completion's 16-bit VLAN TCI
> and the PVID. Now comparing only the relevant 12 bits corresponding to
> the VID.
> Renamed 'vid' field under Rx Completion to 'vlan_tag' to reflect
> accurate description.
> 
> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>

Applied, thanks.
