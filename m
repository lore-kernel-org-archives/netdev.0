From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC 0/2] tun: lockless xmit
Date: Wed, 13 Apr 2016 16:17:44 +0300
Message-ID: <20160413161558-mutt-send-email-mst@redhat.com>
References: <cover.1460393493.git.pabeni@redhat.com>
 <20160413132816-mutt-send-email-mst@redhat.com>
 <1460551817.10638.7.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160413155146-mutt-send-email-mst@redhat.com>
 <1460552966.10638.12.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg Kurz <gkurz@linux.vnet.ibm.com>,
	Jason Wang <jasowang@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41340 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760672AbcDMNRs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2016 09:17:48 -0400
Content-Disposition: inline
In-Reply-To: <1460552966.10638.12.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 13, 2016 at 06:09:26AM -0700, Eric Dumazet wrote:
> You really need to convince John Fastabend to work full time on the real
> thing

Meaning making all qdiscs themselves lockless? With complex policies
like codel I can see how that might be challenging ...

-- 
MST
