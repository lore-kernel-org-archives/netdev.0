From: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC] RESEND - rdmatool - tool for RDMA users
Date: Wed, 18 Jan 2017 18:48:21 +0200
Message-ID: <CAJ3xEMgO496ctgCUp1sW=-pCUyniy7LZb8hSkyNeYsJ1V4aVwg@mail.gmail.com>
References: <CABvr3-GZQs51Sn3XagTsepsy3CHvx6P=GVJzefajbNt9jxz9Kg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ariel Almog <arielalmogworkemails-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CABvr3-GZQs51Sn3XagTsepsy3CHvx6P=GVJzefajbNt9jxz9Kg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 18, 2017 at 5:19 PM, Ariel Almog
<arielalmogworkemails-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> General
> *******
> As of today, there is no single, simple, tool that allows monitoring
> and configuration of RDMA stack.

Before tool, what kernel UAPI you thought to use?


> rdmatool will provide standard, provider agnostic, user interface.
> RDMA user can use this interface to
> * Query RDMA device capabilities
> * Query RDMA device status and current open resources
> * Fetching RDMA statistics
> * Configure RDMA device
>
> The rdmatool will have the ability to control RDMA stack which
> includes the ib_device and RDMA protocol params.
>
> It is a good point to highlight the similarity to ethtool. It manages
> net_device, while rdmatool will manage RDMA stack.
>
> As a proposal, it is appealing to have a similar design to ethtool for
> rdmatool too. As ethtool, it should contain user space part, kernel
> handler and vendor specific handler(s).
>
> Another tool which allows similar functionality is iproute2. Iproute2
> allows user space tools to configure and query transport, network and
> link layer. The advantages of using iproute2 is the reuse of existing
> tool and familiar interface in addition to the wide spreading of this too=
l.
>
> As start point of the discussion, we would like to propose two
> implementation options for the rdmatool:
> (1) Build a tool using ABI interface. This will be a RDMA tool
>     which will be distributed as part of RDMA package
> (2) Enhancing iproute2 to include rdmatool functionality
>
> Our opinion is that the new ABI interface provides vast functionality and
> it will be a waste to use other interface for the same functionality.
> Each of the proposed implementation above have their advantages, and we
> would like to hear your opinion regarding this direction.

> I=E2=80=99m posting this RFC in both netdev and linux-rdma communities in
> order to get feedback on this topic.

What's wrong with the RDMA netlink infrastructure?! it's there for
years and used
for various cases by MLNX, did you look on the code?

cea05ea IB/core: Add flow control to the portmapper netlink calls
ae43f82 IB/core: Add IP to GID netlink offload
2ca546b IB/sa: Route SA pathrecord query through netlink
753f618 RDMA/cma: Add support for netlink statistics export
b2cbae2 RDMA: Add netlink infrastructure
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
