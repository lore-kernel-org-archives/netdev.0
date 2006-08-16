From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH2 1/1] network memory allocator.
Date: Wed, 16 Aug 2006 09:57:12 -0700
Message-ID: <20060816095712.120b3171@localhost.localdomain>
References: <20060814110359.GA27704@2ka.mipt.ru>
	<20060816075137.GA22397@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:28653 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750700AbWHPQ5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 12:57:42 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060816075137.GA22397@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IMHO the network memory allocator is being a little too focused on one problem,
rather than looking at a general enhancement.

Have you looked into something like the talloc used by Samba (and others)?
	http://talloc.samba.org/
	http://samba.org/ftp/unpacked/samba4/source/lib/talloc/talloc_guide.txt

By having a context, we could do better resource tracking and also cleanup
would be easier on removal.
