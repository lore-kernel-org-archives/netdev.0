From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH v9 00/16] Provide a zero-copy method on KVM
 virtio-net.
Date: Mon, 13 Sep 2010 14:35:53 -0700
Message-ID: <1284413753.13351.17.camel@localhost.localdomain>
References: <1281086624-5765-1-git-send-email-xiaohui.xin@intel.com>
	 <1281489804.3391.23.camel@localhost.localdomain>
	 <1281490993.3391.25.camel@localhost.localdomain>
	 <1281506460.3391.42.camel@localhost.localdomain>
	 <1281509704.3391.45.camel@localhost.localdomain>
	 <20100903105233.GA32193@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, davem@davemloft.net,
	herbert@gondor.hengli.com.au, jdike@linux.intel.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100903105233.GA32193@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-09-03 at 13:52 +0300, Michael S. Tsirkin wrote:
> > When binding vhost thread to cpu3, qemu I/O thread to cpu2, macvtap
> zero
> > copy patch can get 9.4Gb/s. 
> > 
> > TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
> 192.168.10.74 (192.168.10.74) port 0 AF_INET : cpu bind
> > Recv   Send    Send                          Utilization
> Service Demand
> > Socket Socket  Message  Elapsed              Send     Recv     Send
> Recv
> > Size   Size    Size     Time     Throughput  local    remote   local
> remote
> > bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB
> us/KB
> > 
> >  87380  16384  65536    60.00      9408.19   55.69    8.45     0.970
> 0.589
> > 
> > Shirley
> 
> OTOH CPU utilization is up too.

w/i macvtap zero copy patch, the BW can reach link w/i more cpu usage,
w/o macvtap zero copy patch, the BW can't be up to link speed. To
achieve same BW, CPU utilization is lower when using zero copy.

Shirley

