From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [RFC PATCH net-next] virtio_net: Support UDP Tunnel offloads.
Date: Mon, 19 Dec 2016 09:26:49 -0500
Message-ID: <abd81d97-c692-a45c-8f08-c31d2e894e9e@redhat.com>
References: <1479423717-2339-1-git-send-email-jarno@ovn.org>
 <CAJ3xEMh79catGjC4p7EsCqix_fmUgbcDtaz-1OUnR2xFpNq99g@mail.gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        james.zhangming@huawei.com,
        "Michael S. Tsirkin <mst@redhat.com> (mst@redhat.com)"
        <mst@redhat.com>, ailan@redhat.com
To: Or Gerlitz <gerlitz.or@gmail.com>, Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38568 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932603AbcLSO0w (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Dec 2016 09:26:52 -0500
In-Reply-To: <CAJ3xEMh79catGjC4p7EsCqix_fmUgbcDtaz-1OUnR2xFpNq99g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/15/2016 02:07 AM, Or Gerlitz wrote:
> On Fri, Nov 18, 2016 at 1:01 AM, Jarno Rajahalme <jarno@ovn.org> wrote:
>> This patch is a proof-of-concept I did a few months ago for UDP tunnel
>> offload support in virtio_net interface [..]
> 
> What's the use case you were considering for a guest running a UDP based VTEP?

Two cases that I've been aware of are nested virt or simply a guest acting
as router/bridge with possible different tunnel devices.

-vlad

> 
>> Real implementation needs to extend the virtio_net header rather than
>> piggy-backing on existing fields.  Inner MAC length (or inner network
>> offset) also needs to be passed as a new field.  Control plane (QEMU)
>> also needs to be updated.
>>
>> All testing was done using Geneve, but this should work for all UDP
>> tunnels the same.
