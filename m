From: Jerry Chu <hkchu@google.com>
Subject: Re: [net-next rfc 3/3] tuntap: increase the max queues to 16
Date: Wed, 19 Jun 2013 12:16:13 -0700
Message-ID: <CAPshTChc_wC1=VNNPHUpjf+P9qRn43MA7YADngL5_Lofqs3rhA@mail.gmail.com>
References: <1371620452-49349-1-git-send-email-jasowang@redhat.com>
	<1371620452-49349-4-git-send-email-jasowang@redhat.com>
	<1371623653.3252.268.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jason Wang <jasowang@redhat.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, mst@redhat.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:44742 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757296Ab3FSTQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 15:16:14 -0400
Received: by mail-lb0-f177.google.com with SMTP id 10so5031691lbf.36
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 12:16:13 -0700 (PDT)
In-Reply-To: <1371623653.3252.268.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 18, 2013 at 11:34 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2013-06-19 at 13:40 +0800, Jason Wang wrote:
>> Since we've reduce the size of tun_struct and use flex array to allocate netdev
>> queues, it's safe for us to increase the limit of queues in tuntap.
>
> Its already safe to increase max queues to 16, without your patches 1 &
> 2

How about 32? Will kmem size be an issue?

As others have pointed out it's best to allocate one queue per CPU
(virtual or real)
and > 16 CPU machines are very common. (I only asked for 16 initially
out of concern
for kmem size.)

Thanks,

Jerry

>
>
>
