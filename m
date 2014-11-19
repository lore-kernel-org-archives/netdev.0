From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-net 0/4] Increase the limit of tuntap queues
Date: Wed, 19 Nov 2014 15:16:28 -0500 (EST)
Message-ID: <20141119.151628.768548269128919029.davem@davemloft.net>
References: <1416327778-17716-1-git-send-email-pagupta@redhat.com>
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
In-Reply-To: <1416327778-17716-1-git-send-email-pagupta@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pankaj Gupta <pagupta@redhat.com>
Date: Tue, 18 Nov 2014 21:52:54 +0530

> - Accept maximum number of queues as sysctl param so that any user space 
>   application like libvirt can use this value to limit number of queues. Also
>   Administrators can specify maximum number of queues by updating this sysctl
>   entry.

This is the only part I don't like.

Just let whoever has privileges to configure the tun device shoot
themselves in the foot if they want to by configuring "too many"
queues.

If the virtual entity runs itself out of resources by doing something
stupid, it's purely their problem.
