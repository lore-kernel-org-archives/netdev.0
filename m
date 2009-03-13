From: David Miller <davem@davemloft.net>
Subject: Re: r8169 skb leak
Date: Fri, 13 Mar 2009 15:33:14 -0700 (PDT)
Message-ID: <20090313.153314.242062968.davem@davemloft.net>
References: <20090313.133640.130060599.davem@davemloft.net>
	<20090313211008.GA14796@redhat.com>
	<20090313222618.GB28021@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davej@redhat.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58936
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758967AbZCMWd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 18:33:28 -0400
In-Reply-To: <20090313222618.GB28021@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri, 13 Mar 2009 23:26:18 +0100

> Dave Jones <davej@redhat.com> :
> > r8169 seems to have the same problem that the via-velocity did with skb padding.
> > Found by code-inspection only, no hardware to test.
> 
> Davem, can you defer this one until now + 24h ?
> 
> The hardware is supposed to auto-pad: I'd rather check it does with
> a few adapters and remove this code altogether.

Sure.

