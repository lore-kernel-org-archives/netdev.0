From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Phonet:fix build problem
Date: Sat, 21 Mar 2009 16:59:50 -0700 (PDT)
Message-ID: <20090321.165950.248659848.davem@davemloft.net>
References: <20090320115838.GA26371@orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: a.beregalov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35410
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754511AbZCVAAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 20:00:02 -0400
In-Reply-To: <20090320115838.GA26371@orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Beregalov <a.beregalov@gmail.com>
Date: Fri, 20 Mar 2009 14:58:38 +0300

> net/phonet/pep.c: In function 'pipe_rcv_status':
> net/phonet/pep.c:262: error: lvalue required as left operand of assignment
> 
> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>

What platform hits this problem?

I think that platform's atomic_add() implementation should
be fixed instead.
