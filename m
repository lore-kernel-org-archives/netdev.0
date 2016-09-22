From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH net-next 0/9] rxrpc: Preparation for slow-start algorithm
Date: Thu, 22 Sep 2016 09:10:26 +0100
Message-ID: <12907.1474531826@warthog.procyon.org.uk>
References: <147450474784.14691.229861132515739820.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39192 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751895AbcIVIK2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Sep 2016 04:10:28 -0400
In-Reply-To: <147450474784.14691.229861132515739820.stgit@warthog.procyon.org.uk>
Content-ID: <12906.1474531826.1@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm going to post a V2 for this.  I've used a couple of 64-bit division
operators rather than calling the appropriate function (which is fine on
x86_64) and managed to transpose the last two patches (causing an undefined
symbol in one of them).

David
