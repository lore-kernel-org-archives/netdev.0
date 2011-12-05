From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next RFC PATCH 2/5] tuntap: simple flow director support
Date: Mon, 5 Dec 2011 20:09:23 +0000
Message-ID: <1323115763.2887.12.camel@bwh-desktop>
References: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
	 <20111205085857.6116.99252.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <krkumar2@in.ibm.com>, <kvm@vger.kernel.org>, <mst@redhat.com>,
	<netdev@vger.kernel.org>, <rusty@rustcorp.com.au>,
	<virtualization@lists.linux-foundation.org>,
	<levinsasha928@gmail.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20111205085857.6116.99252.stgit@dhcp-8-146.nay.redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-12-05 at 16:58 +0800, Jason Wang wrote:
> This patch adds a simple flow director to tun/tap device. It is just a
> page that contains the hash to queue mapping which could be changed by
> user-space. The backend (tap/macvtap) would query this table to get
> the desired queue of a packets when it send packets to userspace.

This is just flow hashing (RSS), not flow steering.

> The page address were set through a new kind of ioctl - TUNSETFD and
> were pinned until device exit or another new page were specified.
[...]

You should implement ethtool ETHTOOL_{G,S}RXFHINDIR instead.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

