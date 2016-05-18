From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] tuntap: introduce tx skb ring
Date: Wed, 18 May 2016 10:16:31 +0200
Message-ID: <20160518101631.368e3447@redhat.com>
References: <1463361421-4397-1-git-send-email-jasowang@redhat.com>
	<20160516070012-mutt-send-email-mst@redhat.com>
	<57397C2B.7000603@redhat.com>
	<20160516105434-mutt-send-email-mst@redhat.com>
	<573A761D.8080909@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, "Michael S. Tsirkin" <mst@redhat.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <573A761D.8080909@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tue, 17 May 2016 09:38:37 +0800 Jason Wang <jasowang@redhat.com> wrote:

> >> And if tx_queue_length is not power of 2,
> >> we probably need modulus to calculate the capacity.  
> > Is that really that important for speed?  
> 
> Not sure, I can test.

In my experience, yes, adding a modulus does affect performance.

> > If yes, round it up to next power of two.  
> 
> Right, this sounds a good solution.

Good idea.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
