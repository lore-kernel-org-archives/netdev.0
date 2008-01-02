From: David Miller <davem@davemloft.net>
Subject: Re: [ICMP]: change "struct socket *" percpu var to a "struct sock
 *"
Date: Tue, 01 Jan 2008 19:21:11 -0800 (PST)
Message-ID: <20080101.192111.75000132.davem@davemloft.net>
References: <477A8A7D.3000301@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55860
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753803AbYABDVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2008 22:21:12 -0500
In-Reply-To: <477A8A7D.3000301@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 01 Jan 2008 19:46:21 +0100

> Instead of storing a pointer to a 'struct socket' and dereferencing ->sk
> to get "struct sock *" from it, just store a "struct sock *" pointer.
> 
> This saves 75 bytes of text on x86
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
