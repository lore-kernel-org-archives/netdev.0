From: jamal <hadi@cyberus.ca>
Subject: Re: netlink question
Date: Thu, 11 Apr 2002 07:41:04 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0204110732000.651-100000@shell.cyberus.ca>
References: <20020410132025.A8595@balabit.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Balazs Scheidler <bazsi@balabit.hu>
In-Reply-To: <20020410132025.A8595@balabit.hu>
List-Id: netdev.vger.kernel.org




On Wed, 10 Apr 2002, Balazs Scheidler wrote:

> Hi,
>
> As I need to communicate between two parts of the kernel (a core TCP part,
> and a loaded module), Andi suggested to use netlink for this purpose.
>
> Since I'm not too familiar with Netlink (and I saw only userspace-kernel
> communication using netlink), I'd need some introductory material about
> netlink. Is some information about the subject available? Sample code would
> be sufficient as well.
>

Look at notifier_chain_un/register(),un/register_netdevice_notifier(),
and their usage. You could also look at the usage of netdev_state_change()

cheers,
jamal
