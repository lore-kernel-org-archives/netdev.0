From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next 2/2] net: reset transport header if it was not
 set before transmission
Date: Tue, 19 Mar 2013 17:26:45 +0800
Message-ID: <51482F55.8020900@redhat.com>
References: <1363333305-54398-1-git-send-email-jasowang@redhat.com> <1363333305-54398-2-git-send-email-jasowang@redhat.com> <1363399851.29475.52.camel@edumazet-glaptop> <20130317.121318.1869489921021513474.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48915 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754022Ab3CSJ0z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 05:26:55 -0400
In-Reply-To: <20130317.121318.1869489921021513474.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/18/2013 12:13 AM, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 15 Mar 2013 19:10:51 -0700
>
>> Any way we can avoid adding this to fast path, for people not using
>> macvtap and ixgbe ?
> Likewise I'd rather see macvtap be responsible for fixing this up by
> setting the transport header properly, and therfore sending well
> formed packets to the rest of the stack.

Ok, haven't checked all other possibility but looks like packet needs to
be fixed also.
