From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [RFC] RESEND - rdmatool - tool for RDMA users
Date: Wed, 18 Jan 2017 19:50:26 +0200
Message-ID: <CAJ3xEMiR1+NGghUZJ6aGq+=xTdOHU5Ph-BcPii5OUB8dT4Vq-A@mail.gmail.com>
References: <CABvr3-GZQs51Sn3XagTsepsy3CHvx6P=GVJzefajbNt9jxz9Kg@mail.gmail.com>
 <CAJ3xEMgO496ctgCUp1sW=-pCUyniy7LZb8hSkyNeYsJ1V4aVwg@mail.gmail.com> <20170118173327.GF32481@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ariel Almog <arielalmogworkemails@gmail.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Leon Romanovsky <leonro@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f193.google.com ([74.125.82.193]:34573 "EHLO
        mail-ot0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753356AbdARRuc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 12:50:32 -0500
In-Reply-To: <20170118173327.GF32481@mtr-leonro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 18, 2017 at 7:33 PM, Leon Romanovsky wrote:
> On Wed, Jan 18, 2017 at 06:48:21PM +0200, Or Gerlitz wrote:
>> On Wed, Jan 18, 2017 at 5:19 PM, Ariel Almog
>> <arielalmogworkemails@gmail.com> wrote:

>>> As of today, there is no single, simple, tool that allows monitoring
>>> and configuration of RDMA stack.

>> Before tool, what kernel UAPI you thought to use?

> I'm aware of the following options:
> 1) netlink
> 2) RDMA ABI https://www.spinics.net/lists/linux-rdma/msg43960.html
> 3) ioctl
> 4) write/read
>
> The items 1 and 2 are preferred options and one of the main goals
> for this RFC is to chose between them.
>
> For example, RDMA ABI has native support of querying and discovering
> device capabilities via merge tree feature.

To make it clear, when you wrote ABI in your initial email, I tend to
think it was sort of unclear to the netdev crowd that you are talking
on new UAPI which is now under the works for the IB subsystem, so with
my netdev community member hat, I got confused... anyway


>> > It is a good point to highlight the similarity to ethtool. It manages
>> > net_device, while rdmatool will manage RDMA stack.

ethtool is likely to be ported to use netlink somewhere in the 21st century BTW


>> What's wrong with the RDMA netlink infrastructure?! it's there for
>> years and used
>> for various cases by MLNX, did you look on the code?

> Nothing wrong, it is one of the valuable options and will be used if
> community decides to put this tool under iproute2/ethtool umbrella.

yeah, using netlink sounds good to me, and where you package/maintain
the tool is of 2nd order, 1st decide what UAPI you wonna use. So far
netlink was good for what bunch of use-cases needed.

Or.

>> cea05ea IB/core: Add flow control to the portmapper netlink calls
>> ae43f82 IB/core: Add IP to GID netlink offload
>> 2ca546b IB/sa: Route SA pathrecord query through netlink
>> 753f618 RDMA/cma: Add support for netlink statistics export
>> b2cbae2 RDMA: Add netlink infrastructure
