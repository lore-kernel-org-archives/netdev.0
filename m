From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [PATCH nf-next] netfilter: xt_socket: add XT_SOCKET_NOWILDCARD
 flag
Date: Tue, 4 Jun 2013 11:10:14 +0200
Message-ID: <20130604111014.73c718f7@redhat.com>
References: <1370300249.24311.190.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56207 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750889Ab3FDJK2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jun 2013 05:10:28 -0400
In-Reply-To: <1370300249.24311.190.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 03 Jun 2013 15:57:29 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> xt_socket module can be a nice replacement to conntrack module
> in some cases (SYN filtering for example)
> 
> But it lacks the ability to match the 3rd packet of TCP
> handshake (ACK coming from the client).
> 
> Add a XT_SOCKET_NOWILDCARD flag to disable the wildcard mechanism

Sorry, but I'm not sure I understand your description.

What is the effect of adding the XT_SOCKET_NOWILDCARD flag?
It almost sound like it adds the ability to match the 3rd packet of TCP
handshake (ACK coming from the client), is that the case?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
