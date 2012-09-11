From: Cong Wang <amwang@redhat.com>
Subject: RE: [PATCH 2/3] ipv6, route: remove BACKTRACK() macro
Date: Tue, 11 Sep 2012 09:07:37 +0800
Message-ID: <1347325657.30731.5.camel@cr0>
References: <1347281326-26890-1-git-send-email-amwang@redhat.com>
	 <1347281326-26890-2-git-send-email-amwang@redhat.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B6FE6@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38360 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751438Ab2IKBHt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2012 21:07:49 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6FE6@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-10 at 14:54 +0100, David Laight wrote:
> 
> It does, however, seem to avoid replicating some relatively complex logic.
> OTOH goto out of a #define and hidden parameters (rt, fn ...) are not nice.
> 
> Maybe the 'while (1)' part can be an inline function?
> 

Yeah, actually that goto is the main reason why I think it should be
removed, at least I myself have some difficult to read this code which
jumps out. ;)
