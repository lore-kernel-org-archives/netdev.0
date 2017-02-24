From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rxrpc: Fix an assertion in rxrpc_read()
Date: Fri, 24 Feb 2017 11:21:40 -0500 (EST)
Message-ID: <20170224.112140.1652689255202011736.davem@davemloft.net>
References: <148793958900.27516.14977364495699700677.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37044 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751192AbdBXQYS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 11:24:18 -0500
In-Reply-To: <148793958900.27516.14977364495699700677.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Fri, 24 Feb 2017 12:33:09 +0000

> From: Marc Dionne <marc.dionne@auristor.com>
> 
> In the rxrpc_read() function, which allows a user to read the contents of a
> key, we miscalculate the expected length of an encoded rxkad token by not
> taking into account the key length.  However, the data is stored later
> anyway with an ENCODE_DATA() call - and an assertion failure then ensues
> when the lengths are checked at the end.
> 
> Fix this by including the key length in the token size estimation.
> 
> The following assertion is produced:
 ...
> Signed-off-by: Marc Dionne <marc.dionne@auristor.com>
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied.
