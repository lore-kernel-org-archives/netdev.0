From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2][RFC] vlan: use pskb_copy() when inserting a vlan
 tag by hand
Date: Tue, 08 Jul 2008 22:15:55 +0200
Message-ID: <4873CAFB.8040606@trash.net>
References: <20080707205646.GB12997@xi.wantstofly.org> <4872841E.1030609@trash.net> <20080707210701.GD12997@xi.wantstofly.org> <48728784.2030202@trash.net> <487394CC.7050107@trash.net> <20080708185226.GD14330@xi.wantstofly.org> <4873B6E1.9010702@trash.net> <20080708193351.GE14330@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nicolas Pitre <nico@cam.org>,
	Dale Farnsworth <dale@farnsworth.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Jesper Dangaard Brouer <jdb@comx.dk>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38092 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620AbYGHUP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 16:15:57 -0400
In-Reply-To: <20080708193351.GE14330@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek wrote:
> On Tue, Jul 08, 2008 at 08:50:09PM +0200, Patrick McHardy wrote:
> 
>> commit 9381fc4a49cb8b75d5ff38e4f5d14d7e135adc4c
>> Author: Patrick McHardy <kaber@trash.net>
>> Date:   Tue Jul 8 19:56:17 2008 +0200
>>
>>     vlan: avoid header copying and linearisation where possible
> 
> That gives me:
> 
> - 2.6.26-rc9 + [1] + [2] + this patch: ~75 sec, 13.6 MiB/s
> 
> So it's almost back to the non-VLAN case.


Great, thanks. The patch applies cleanly with or without the VLAN
packet socket patches I sent today, so Dave can either just apply
it together with your mv643xx_eth patch or I'll include it when
sending the next VLAN update.

