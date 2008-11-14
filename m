From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: use %pI4, remove get_{u8/u16/u32} and
 put_{u8/u16/u32} inlines
Date: Thu, 13 Nov 2008 22:42:07 -0800 (PST)
Message-ID: <20081113.224207.25857066.davem@davemloft.net>
References: <1226639846.5483.3.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kkeil@suse.de
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50707
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750777AbYKNGmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 01:42:08 -0500
In-Reply-To: <1226639846.5483.3.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Thu, 13 Nov 2008 21:17:25 -0800

> They would have been better named as get_be16, put_be16, etc.
> as they were hiding an endian shift inside.
> 
> They don't add much over explicitly coding the byteshifting
> and gcc sometimes has a problem with builtin_constant_p inside
> inline functions, so it may do a better job of byteswapping
> at compile time rather than runtime.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Applied, thanks Harvey.
