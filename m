From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next PATCH V3 0/2] qdisc bulk dequeuing and utilizing
 delayed tailptr updates
Date: Fri, 19 Sep 2014 14:45:26 -0700
Message-ID: <1411163126.26859.40.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140919204706.3231.59125.stgit@dragon>
	 <1411160360.26859.31.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140919233108.5bd43ccc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>, toke@toke.dk
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:58828 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757728AbaISVp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 17:45:28 -0400
Received: by mail-pa0-f41.google.com with SMTP id ey11so992776pad.0
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 14:45:28 -0700 (PDT)
In-Reply-To: <20140919233108.5bd43ccc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-19 at 23:31 +0200, Jesper Dangaard Brouer wrote:

> How can I test if the dev supports BQL?


CONFIG_BQL should be enough.

If a device driver do nothing about BQL, byte_queue_limits/limit will be
zero by default.
