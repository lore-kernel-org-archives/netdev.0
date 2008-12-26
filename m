From: David Miller <davem@davemloft.net>
Subject: Re: [patch 07/10] 802.3ad: use standard ethhdr instead of ad_header
Date: Fri, 26 Dec 2008 13:41:59 -0800 (PST)
Message-ID: <20081226.134159.167533997.davem@davemloft.net>
References: <20081223220101.747816175@jonathan.eitzenberger.org>
	<20081223220559.192000322@jonathan.eitzenberger.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org
To: holger@eitzenberger.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55957
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752880AbYLZVl4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 16:41:56 -0500
In-Reply-To: <20081223220559.192000322@jonathan.eitzenberger.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Holger Eitzenberger <holger@eitzenberger.org>
Date: Tue, 23 Dec 2008 23:01:08 +0100

> 802.3ad has its own ethhdr-like structure in the form of an ad_header,
> which is at the start of both the LACPDU and marker PDU.  Both are
> the same from the struct values, both are packed as well.
> 
> It's therefore perfectly fine to replace the ad_header by the ethhdr
> and to remove its definition.
> 
> Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Applied.
