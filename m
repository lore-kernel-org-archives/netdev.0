From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next 1/8] net: move netdev_upper to netdevice.h
Date: Mon, 26 Aug 2013 20:10:32 +0200
Message-ID: <20130826181032.GA29952@redhat.com>
References: <1377534533-6944-1-git-send-email-vfalico@redhat.com>
 <1377534533-6944-2-git-send-email-vfalico@redhat.com>
 <20130826164115.GA1413@minipsycho.brq.redhat.com>
 <20130826165535.GG1992@redhat.com>
 <20130826173844.GA1437@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16153 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752520Ab3HZSLw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Aug 2013 14:11:52 -0400
Content-Disposition: inline
In-Reply-To: <20130826173844.GA1437@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 26, 2013 at 07:38:44PM +0200, Jiri Pirko wrote:
>I was imagine something like:
>
>struct list_head *iter;
>struct net_device *dev, *upper;
>
>netdev_for_each_upper_dev(dev, upper, iter) {
>
>}
>
>This macro can be easily implented using netdev_upper_get_next_dev()
>from dev.c
>
>Not much of added overhead other than netdev_upper_get_next_dev calls
>(without any search when using list_head iter).

Great idea, didn't think of it.

Thanks a lot, will try implement it and send v2.
