From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2] tuntap: hardware vlan tx support
Date: Sat, 27 Jul 2013 20:09:40 -0700 (PDT)
Message-ID: <20130727.200940.1407377271115722165.davem@davemloft.net>
References: <1374728433-19843-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	basil.gor@gmail.com, mst@redhat.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1374728433-19843-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Thu, 25 Jul 2013 13:00:33 +0800

> Inspired by commit f09e2249c4f5c7c13261ec73f5a7807076af0c8e (macvtap: restore
> vlan header on user read). This patch adds hardware vlan tx support for
> tuntap. This is done by copying vlan header directly into userspace in
> tun_put_user() instead of doing it through __vlan_put_tag() in
> dev_hard_start_xmit(). This eliminates one unnecessary memmove() in
> vlan_insert_tag() for 802.1ad and 802.1q traffic.
> 
> pktgen test shows about 20% improvement for 802.1q traffic:
> 
> Before:
>   662149pps 317Mb/sec (317831520bps) errors: 0
> After:
>   801033pps 384Mb/sec (384495840bps) errors: 0
> 
> Cc: Basil Gor <basil.gor@gmail.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied, thanks Jason.
