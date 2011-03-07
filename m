From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: [PATCH 13/17] mlx4: Add blue flame support for kernel consumers
Date: Mon, 7 Mar 2011 23:48:12 +0200
Message-ID: <20110307214812.GA19540@mtldesk30>
References: <CFE9BFE80FFE4D4892AA5D31387E310F02F3ED@mtldag01.mtl.com>
 <20110307213648.GA18682@mtldesk30>
 <20110307.134001.245386278.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roland@purestorage.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:57238 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755246Ab1CGVqN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 16:46:13 -0500
Received: by ewy6 with SMTP id 6so1728402ewy.19
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2011 13:46:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20110307.134001.245386278.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 07, 2011 at 01:40:01PM -0800, David Miller wrote:
> From: Eli Cohen <eli@dev.mellanox.co.il>
> Date: Mon, 7 Mar 2011 23:36:48 +0200
> 
> > Specifically, some archs may not support write combining.
> 
> They should just create a non-write-combining mapping if they
> don't support it.
> 

I wouldn't expect that since the caller function could be mislead to
believe it has a write combining capable area.
