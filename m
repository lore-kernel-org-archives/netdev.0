From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bnx2x: Dont update vlan_features in
 bnx2x_set_tso()
Date: Sun, 26 Jul 2009 19:49:20 -0700 (PDT)
Message-ID: <20090726.194920.212730625.davem@davemloft.net>
References: <1248394379.13301.2.camel@HP1>
	<4A6960EF.5020204@gmail.com>
	<1248605623.18195.58.camel@lb-tlvb-eilong>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, mchan@broadcom.com, ogerlitz@voltaire.com,
	kaber@trash.net, fubar@us.ibm.com, netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56702
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755748AbZG0CtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2009 22:49:14 -0400
In-Reply-To: <1248605623.18195.58.camel@lb-tlvb-eilong>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Sun, 26 Jul 2009 13:53:43 +0300

> On Fri, 2009-07-24 at 00:21 -0700, Eric Dumazet wrote:
>> Based on Patrick feedback, I believe we can add this followup too
>> 
>> [PATCH net-next-2.6] bnx2x: Dont update vlan_features in bnx2x_set_tso()
>> 
>> Patrick said : "vlan_features doesn't need to be updated, the resulting
>> dev->features of the VLAN device is computed as the intersection of
>> dev->features and dev->vlan_features."
>> 
> Thanks Eric
> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Acked-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thanks.
