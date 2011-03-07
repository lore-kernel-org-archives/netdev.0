From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: [PATCH 13/17] mlx4: Add blue flame support for kernel consumers
Date: Mon, 7 Mar 2011 23:58:03 +0200
Message-ID: <20110307215803.GB19540@mtldesk30>
References: <20110307213648.GA18682@mtldesk30>
 <20110307.134001.245386278.davem@davemloft.net>
 <20110307214812.GA19540@mtldesk30>
 <20110307.134931.232736253.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roland@purestorage.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41809 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755693Ab1CGV4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 16:56:01 -0500
Received: by wyg36 with SMTP id 36so4634810wyg.19
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2011 13:56:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20110307.134931.232736253.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 07, 2011 at 01:49:31PM -0800, David Miller wrote:
> 
> It's a performance optimization, if you don't get write combining you'll
> get more strict ordering, rather than less.
> 
> It cannot cause problem.

I agree, but the function could still fail and the caller's logic
could attempt to call ioreamp or take other action. For example, in
the case of blue flame, it is better performance-wise to avoid using
this feature if write combining is not available.
