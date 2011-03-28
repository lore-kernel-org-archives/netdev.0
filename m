From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] irda: prevent heap corruption on invalid nickname
Date: Sun, 27 Mar 2011 17:59:14 -0700 (PDT)
Message-ID: <20110327.175914.71098822.davem@davemloft.net>
References: <1300601670.1869.5.camel@dan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org, security@kernel.org
To: drosenberg@vsecurity.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45902
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752553Ab1C1A7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 20:59:53 -0400
In-Reply-To: <1300601670.1869.5.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Rosenberg <drosenberg@vsecurity.com>
Date: Sun, 20 Mar 2011 02:14:30 -0400

> Invalid nicknames containing only spaces will result in an underflow in
> a memcpy size calculation, subsequently destroying the heap and
> panicking.
> 
> v2 also catches the case where the provided nickname is longer than the
> buffer size, which can result in controllable heap corruption.
> 
> Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
> Cc: stable@kernel.org

Applied.
