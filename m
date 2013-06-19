From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next rfc 3/3] tuntap: increase the max queues to 16
Date: Wed, 19 Jun 2013 15:15:40 +0800
Message-ID: <51C15A9C.3080900@redhat.com>
References: <1371620452-49349-1-git-send-email-jasowang@redhat.com>  <1371620452-49349-4-git-send-email-jasowang@redhat.com> <1371623653.3252.268.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, hkchu@google.com,
	mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371623653.3252.268.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/19/2013 02:34 PM, Eric Dumazet wrote:
> On Wed, 2013-06-19 at 13:40 +0800, Jason Wang wrote:
>> Since we've reduce the size of tun_struct and use flex array to allocate netdev
>> queues, it's safe for us to increase the limit of queues in tuntap.
> Its already safe to increase max queues to 16, without your patches 1 &
> 2
>
>
>

Will send a single patch to increase it to 16.

Thanks
