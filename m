From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2] net-tun: restructure tun_do_read for better
 sleep/wakeup efficiency
Date: Tue, 20 May 2014 09:35:51 +0300
Message-ID: <20140520063551.GC6653@redhat.com>
References: <1400278308-25372-1-git-send-email-xii@google.com>
 <5379CE8D.2030405@redhat.com>
 <1400508587.5367.37.camel@edumazet-glaptop2.roam.corp.google.com>
 <537ADD91.4000609@redhat.com>
 <1400561559.5367.87.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, Xi Wang <xii@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Maxim Krasnyansky <maxk@qti.qualcomm.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25183 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750769AbaETGhC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2014 02:37:02 -0400
Content-Disposition: inline
In-Reply-To: <1400561559.5367.87.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 19, 2014 at 09:52:39PM -0700, Eric Dumazet wrote:
> On Tue, 2014-05-20 at 12:44 +0800, Jason Wang wrote:
> 
> > But this changes (sk_data_ready()) has nothing related to switching to
> > use __skb_recv_datagram()
> 
> I think I will give up at this point, this is becoming too much time to
> gain only 15% of cpu.
> 

Ouch I did like the patch, less code and more performance.
I hope we'll be able to save it still, please be patient
Jason's just being cautious trying to make sure we don't
break existing userspace.


-- 
MST
