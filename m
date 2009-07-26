From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH net-next-2.6] bnx2x: Dont update vlan_features in
 bnx2x_set_tso()
Date: Sun, 26 Jul 2009 13:53:43 +0300
Message-ID: <1248605623.18195.58.camel@lb-tlvb-eilong>
References: <4A681029.4070600@voltaire.com> <4A681F63.7060001@gmail.com>
 <4A685122.3090300@gmail.com>
 <20090723.105932.249439810.davem@davemloft.net>
 <1248394379.13301.2.camel@HP1> <4A6960EF.5020204@gmail.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>,
	"David Miller" <davem@davemloft.net>,
	"ogerlitz@voltaire.com" <ogerlitz@voltaire.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"fubar@us.ibm.com" <fubar@us.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2635 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752449AbZGZKyH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Jul 2009 06:54:07 -0400
In-Reply-To: <4A6960EF.5020204@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-07-24 at 00:21 -0700, Eric Dumazet wrote:
> Based on Patrick feedback, I believe we can add this followup too
> 
> [PATCH net-next-2.6] bnx2x: Dont update vlan_features in bnx2x_set_tso()
> 
> Patrick said : "vlan_features doesn't need to be updated, the resulting
> dev->features of the VLAN device is computed as the intersection of
> dev->features and dev->vlan_features."
> 
Thanks Eric

> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Acked-by: Eilon Greenstein <eilong@broadcom.com>



