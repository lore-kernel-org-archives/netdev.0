From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 2/9] rxrpc: Disable a debugging statement that has been left enabled.
Date: Thu, 07 Apr 2016 18:05:22 +0100
Message-ID: <24286.1460048722@warthog.procyon.org.uk>
References: <1460046677.6715.95.camel@perches.com> <20160407162256.21283.47849.stgit@warthog.procyon.org.uk> <20160407162309.21283.11482.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42150 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751440AbcDGRFZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 13:05:25 -0400
In-Reply-To: <1460046677.6715.95.camel@perches.com>
Content-ID: <24285.1460048722.1@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches <joe@perches.com> wrote:

> It might be better to remove kenter and _enter
> altogether and use function tracing instead.

Possibly - but not at this time.  Besides, isn't the function tracing log lost
if the machine crashes?

David
