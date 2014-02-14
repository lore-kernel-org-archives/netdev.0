From: David Howells <dhowells@redhat.com>
Subject: Re: suspicious code in net/rxrpc/ar-error.c
Date: Fri, 14 Feb 2014 11:21:39 +0000
Message-ID: <20486.1392376899@warthog.procyon.org.uk>
References: <20140214022815.GA19030@redhat.com>
Cc: dhowells@redhat.com, netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55129 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752403AbaBNLVm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 06:21:42 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s1EBLfuU032284
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 14 Feb 2014 06:21:41 -0500
In-Reply-To: <20140214022815.GA19030@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Jones <davej@redhat.com> wrote:

> What was intended here ? Perhaps one of those mtu comparisons should be
> comparing peer->mtu ?

Good spot, thanks.  Yeah, I should be loading mtu with peer->mtu immediately
after the comment.

David
