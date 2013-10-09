From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] tun: don't look at current when non-blocking
Date: Wed, 09 Oct 2013 14:25:19 +0800
Message-ID: <5254F6CF.8080606@redhat.com>
References: <20131006182512.GA16504@redhat.com> <20131008.154614.1435858706789904414.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	edumazet@google.com, xemul@parallels.com
To: David Miller <davem@davemloft.net>, mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131008.154614.1435858706789904414.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/09/2013 03:46 AM, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Sun, 6 Oct 2013 21:25:12 +0300
>
>> We play with a wait queue even if socket is
>> non blocking. This is an obvious waste.
>> Besides, it will prevent calling the non blocking
>> variant when current is not valid.
>>
>> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Applied and queued up for -stable, thanks.
> --

Michael, I believe this is just an optimization or a required patch of
your following patches. So no need go for stable?
