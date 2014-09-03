From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 1/3] virtio_net: pass well-formed sgs to
 virtqueue_add_*()
Date: Wed, 3 Sep 2014 12:23:50 +0200
Message-ID: <20140903122350.1c365bee@redhat.com>
References: <1409718556-3041-1-git-send-email-rusty@rustcorp.com.au>
	<1409718556-3041-2-git-send-email-rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, "netdev" <netdev@vger.kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60548 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754336AbaICKX6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 06:23:58 -0400
In-Reply-To: <1409718556-3041-2-git-send-email-rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  3 Sep 2014 13:59:14 +0930
Rusty Russell <rusty@rustcorp.com.au> wrote:

> pktgen results:
> 	modprobe pktgen
> 	echo 'add_device eth0' > /proc/net/pktgen/kpktgend_0
> 	echo nowait 1 > /proc/net/pktgen/eth0

Maybe your pktgen "nowait" (patch) should be a flag instead?

 echo "flag EXIT_NO_WAIT" > /proc/net/pktgen/eth0

> 	echo count 1000000 > /proc/net/pktgen/eth0
> 	echo clone_skb 100000 > /proc/net/pktgen/eth0
> 	echo dst_mac 4e:14:25:a9:30:ac > /proc/net/pktgen/eth0
> 	echo dst 192.168.1.2 > /proc/net/pktgen/eth0
> 	for i in `seq 20`; do echo start > /proc/net/pktgen/pgctrl; tail -n1 /proc/net/pktgen/eth0; done
> 


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
