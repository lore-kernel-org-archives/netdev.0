From: David Howells <dhowells@redhat.com>
Subject: Getting at the UDP headers from ->data_ready()
Date: Mon, 11 Apr 2016 22:04:09 +0100
Message-ID: <19466.1460408649@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, netdev@vger.kernel.org
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51498 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750925AbcDKVEL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2016 17:04:11 -0400
Content-ID: <19465.1460408649.1@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Willem,

With regards to:

    commit 4d0fc73ebe94ac984a187f21fbf4f3a1ac846f5a
    Author: Willem de Bruijn <willemb@google.com>
    Date:   Thu Apr 7 11:44:59 2016 -0400

    rxrpc: do not pull udp headers on receive
    
    Commit e6afc8ace6dd modified the udp receive path by pulling the udp
    header before queuing an skbuff onto the receive queue.
 
Does that mean that I can no longer access the UDP header via udp_hdr(skb)
from with the ->data_ready() handler?

I'm guessing that's not actually the case since ip_hdr(skb) seems to work - or
is that something I shouldn't be using since the part of the buffer containing
the IP header might've been discarded?

David
