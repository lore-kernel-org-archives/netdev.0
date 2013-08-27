From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v1 1/9] net: add netdev_upper_get_next_dev(dev,
 iter)
Date: Tue, 27 Aug 2013 12:42:15 +0200
Message-ID: <20130827104215.GA24836@redhat.com>
References: <1377549162-7522-1-git-send-email-vfalico@redhat.com>
 <1377549162-7522-2-git-send-email-vfalico@redhat.com>
 <20130826205748.GB3723@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44841 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752776Ab3H0Kne (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Aug 2013 06:43:34 -0400
Content-Disposition: inline
In-Reply-To: <20130826205748.GB3723@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 26, 2013 at 10:57:48PM +0200, Jiri Pirko wrote:
>Mon, Aug 26, 2013 at 10:32:34PM CEST, vfalico@redhat.com wrote:
...snip...
>>+struct net_device *netdev_upper_get_next_dev(struct net_device *dev,
>>+					     struct list_head **iter)
>
>		This should be probably rather named
>		"netdev_upper_get_next_dev_rcu" That way it is clear
>		right away. Also if you introduce non-rcu variant in
>		future, you won't introduce confusion :)

Agreed, it will be easier, will do in v2.
