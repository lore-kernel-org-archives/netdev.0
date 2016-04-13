From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC 0/2] tun: lockless xmit
Date: Wed, 13 Apr 2016 06:43:41 -0700
Message-ID: <1460555021.10638.20.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1460393493.git.pabeni@redhat.com>
	 <20160413132816-mutt-send-email-mst@redhat.com>
	 <1460551817.10638.7.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160413155146-mutt-send-email-mst@redhat.com>
	 <1460552966.10638.12.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160413161558-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg Kurz <gkurz@linux.vnet.ibm.com>,
	Jason Wang <jasowang@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36094 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934296AbcDMNno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 09:43:44 -0400
Received: by mail-pf0-f179.google.com with SMTP id e128so34403219pfe.3
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 06:43:43 -0700 (PDT)
In-Reply-To: <20160413161558-mutt-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-04-13 at 16:17 +0300, Michael S. Tsirkin wrote:
> On Wed, Apr 13, 2016 at 06:09:26AM -0700, Eric Dumazet wrote:
> > You really need to convince John Fastabend to work full time on the real
> > thing
> 
> Meaning making all qdiscs themselves lockless? With complex policies
> like codel I can see how that might be challenging ...

Codel is a fifo, plus some droping capabilities at dequeue time.

It totally can be made lockless.
