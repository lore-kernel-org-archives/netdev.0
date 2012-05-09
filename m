From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC 0/6] copy aside frags with destructors (was [PATCH
 7/9] net: add skb_orphan_frags to copy aside frags with destructors)
Date: Wed, 9 May 2012 18:27:10 +0300
Message-ID: <20120509152709.GA20755@redhat.com>
References: <cover.1336397823.git.mst@redhat.com>
 <1336569529.25514.109.camel@zakaz.uk.xensource.com>
 <20120509135240.GA19246@redhat.com>
 <1336572107.25514.127.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61942 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758144Ab2EIP1J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2012 11:27:09 -0400
Content-Disposition: inline
In-Reply-To: <1336572107.25514.127.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 09, 2012 at 03:01:47PM +0100, Ian Campbell wrote:
> I took a look at a fairly high level and it all looked sensible, I've
> not looked closely at the details, not run it yet, I hope I can do that
> shortly.

In particular you can trace skb_copy_ubufs to verify that
it's called in the scenario where we want a copybreak
and not called where unexpected e.g. in bridge forwarding.
