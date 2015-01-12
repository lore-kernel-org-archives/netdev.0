From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 net-net 0/2] Increase the limit of tuntap queues
Date: Mon, 12 Jan 2015 17:05:51 -0500 (EST)
Message-ID: <20150112.170551.2256606651908771184.davem@davemloft.net>
References: <1421043089-30103-1-git-send-email-pagupta@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jasowang@redhat.com, mst@redhat.com, dgibson@redhat.com,
	vfalico@gmail.com, edumazet@google.com, vyasevic@redhat.com,
	hkchu@google.com, wuzhy@linux.vnet.ibm.com, xemul@parallels.com,
	therbert@google.com, bhutchings@solarflare.com, xii@google.com,
	stephen@networkplumber.org, jiri@resnulli.us,
	sergei.shtylyov@cogentembedded.com
To: pagupta@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421043089-30103-1-git-send-email-pagupta@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pankaj Gupta <pagupta@redhat.com>
Date: Mon, 12 Jan 2015 11:41:27 +0530

> Networking under KVM works best if we allocate a per-vCPU rx and tx
> queue in a virtual NIC. This requires a per-vCPU queue on the host side.
> Modern physical NICs have multiqueue support for large number of queues.
> To scale vNIC to run multiple queues parallel to maximum number of vCPU's
> we need to increase number of queues support in tuntap.   

Series applied, thanks for following up on this.
