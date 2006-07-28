From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/7] NetLabel: core network changes
Date: Fri, 28 Jul 2006 13:24:26 +0200
Message-ID: <20060728112426.GE14627@postel.suug.ch>
References: <20060717155224.060020000@hp.com> <20060717155822.315389000@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, davem@davemloft.net,
	sds@epoch.ncsc.mil, jmorris@redhat.com, pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:30436 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751368AbWG1LYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 07:24:06 -0400
To: paul.moore@hp.com
Content-Disposition: inline
In-Reply-To: <20060717155822.315389000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* paul.moore@hp.com <paul.moore@hp.com> 2006-07-17 11:52
> + * NetLabel makes use of the Generic NETLINK mechanism as a transport layer to
> + * send messages between kernel and user space.  The general format of a
> + * NetLabel message is shown below:
> + *
> + *  +-----------------+-------------------+--------- --- -- -
> + *  | struct nlmsghdr | struct genlmsghdr | payload
> + *  +-----------------+-------------------+--------- --- -- -
> + *
> + * The 'nlmsghdr' and 'genlmsghdr' structs should be dealt with like normal.
> + * The payload is dependent on the subsystem specified in the
> + * 'nlmsghdr->nlmsg_type' and should be defined below, supporting functions
> + * should be defined in the corresponding net/netlabel/netlabel_<subsys>.h|c
> + * file.  All of the fields in the NetLabel payload should be aligned using
> + * the alignment functions provided.
> + *
> + */
> +
> +/*
> + * NetLabel NETLINK protocol
> + */
> +

Is there a reason for not using any of the existing netlink and
genetlink interfaces in any of your patches? It's all duplicated
code.
