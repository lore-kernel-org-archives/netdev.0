From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] udp: disallow UFO for sockets with SO_NO_CHECK option
Date: Mon, 11 Jan 2016 13:19:40 +0100
Message-ID: <56939DDC.8030600@stressinduktion.org>
References: <20160111065030.F3FFCA0EF1@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Michal Kubecek <mkubecek@suse.cz>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160111065030.F3FFCA0EF1@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11.01.2016 07:50, Michal Kubecek wrote:
> Commit acf8dd0a9d0b ("udp: only allow UFO for packets from SOCK_DGRAM
> sockets") disallows UFO for packets sent from raw sockets. We need to do
> the same also for SOCK_DGRAM sockets with SO_NO_CHECK options, even if
> for a bit different reason: while such socket would override the
> CHECKSUM_PARTIAL set by ip_ufo_append_data(), gso_size is still set and
> bad offloading flags warning is triggered in __skb_gso_segment().
>
> In the IPv6 case, SO_NO_CHECK option is ignored but we need to disallow
> UFO for packets sent by sockets with UDP_NO_CHECK6_TX option.
>
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> Tested-by: Shannon Nelson <shannon.nelson@intel.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
