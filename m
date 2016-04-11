From: David Howells <dhowells@redhat.com>
Subject: Re: Getting at the UDP headers from ->data_ready()
Date: Mon, 11 Apr 2016 22:23:33 +0100
Message-ID: <1831.1460409813@warthog.procyon.org.uk>
References: <CAF=yD-JfW6kfoQ4geO3bCCrBVng-AL=BqBuVyF2nU0tO4jpsDg@mail.gmail.com> <19466.1460408649@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: dhowells@redhat.com, Willem de Bruijn <willemb@google.com>,
	Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58029 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752652AbcDKVXf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 17:23:35 -0400
In-Reply-To: <CAF=yD-JfW6kfoQ4geO3bCCrBVng-AL=BqBuVyF2nU0tO4jpsDg@mail.gmail.com>
Content-ID: <1830.1460409813.1@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Willem de Bruijn <willemdebruijn.kernel@gmail.com> wrote:

> The network and transport header pointers are still valid. Commit e6afc8ace6dd
> only  changes where skb->data points to. It does not discard the data between
> skb->head and skb->data. This rxrpc follow-up patch fixes some offset
> arithmetic to the payload, which is computed relative to skb->data.
> 
> There are other uses of ip_hdr and udp_hdr in udp_recvmsg and similar
> recvmsg handlers for other protocols. For instance, in the source address
> processing for recvfrom ("if (sin) { .. }")

Excellent, thanks!

David
