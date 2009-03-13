From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 skb leak
Date: Fri, 13 Mar 2009 23:26:18 +0100
Message-ID: <20090313222618.GB28021@electric-eye.fr.zoreil.com>
References: <49B89385.4090005@cosmosbay.com> <20090312045657.GB7132@redhat.com> <49B89A33.2030207@cosmosbay.com> <20090313.133640.130060599.davem@davemloft.net> <20090313211008.GA14796@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Dave Jones <davej@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:45870 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759940AbZCMWXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 18:23:17 -0400
Content-Disposition: inline
In-Reply-To: <20090313211008.GA14796@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Jones <davej@redhat.com> :
> r8169 seems to have the same problem that the via-velocity did with skb padding.
> Found by code-inspection only, no hardware to test.

Davem, can you defer this one until now + 24h ?

The hardware is supposed to auto-pad: I'd rather check it does with
a few adapters and remove this code altogether.

-- 
Ueimor
