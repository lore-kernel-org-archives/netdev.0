From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ipv4: Restart rt_intern_hash after emergency
 rebuild (v2)
Date: Fri, 26 Mar 2010 20:58:24 -0700 (PDT)
Message-ID: <20100326.205824.143616642.davem@davemloft.net>
References: <4BAA4F3F.70703@openvz.org>
	<4BAB15FA.20108@openvz.org>
	<20100325131721.GA17675@shamino.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, dada1@cosmosbay.com, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52385
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753005Ab0C0D6B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 23:58:01 -0400
In-Reply-To: <20100325131721.GA17675@shamino.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu, 25 Mar 2010 09:17:21 -0400

> On Thu, Mar 25, 2010 at 10:51:22AM +0300, Pavel Emelyanov wrote:
>> The the rebuild changes the genid which in turn is used at
>> the hash calculation. Thus if we don't restart and go on with
>> inserting the rt will happen in wrong chain.
>> 
>> (Fixed Neil's comment about the index passed into the rt_intern_hash)
>> 
>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> Thanks!  I think this is pretty reasonable.
> Reviewed-by: Neil Horman <nhorman@tuxdriver.com>

Applied, thanks.
