From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net 0/2] mlx4: Fix VF MAC address change under RoCE usage
Date: Fri, 16 May 2014 07:58:27 +0300
Message-ID: <CAJZOPZJqqsheFBqcqM8mKYb8o9Ac2vUSRW6bkN6iZQinQwbssA@mail.gmail.com>
References: <1400156968-29633-1-git-send-email-ogerlitz@mellanox.com>
	<20140515.233958.2173839819606514748.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Roland Dreier <roland@kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:44784 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753746AbaEPE62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 00:58:28 -0400
Received: by mail-qc0-f174.google.com with SMTP id x13so3487889qcv.33
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 21:58:27 -0700 (PDT)
In-Reply-To: <20140515.233958.2173839819606514748.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 16, 2014 at 6:39 AM, David Miller <davem@davemloft.net> wrote:
>
> From: Or Gerlitz <ogerlitz@mellanox.com>
> Date: Thu, 15 May 2014 15:29:26 +0300
>
> > Hi Dave, Roland
>
> I don't see Roland Dreier on the CC: list, I have added him.



thanks

>
>
> > This short series provides proper handling for the case where a
> > VF netdevice change their MAC address under a RoCE use case. The code
> > it deals with was introduced in 3.15-rc1
> >
> > Prior to this series the source MAC used for the VM RoCE CM
> > packets remains as before the MAC modification. Hence RoCE CM
> > packets sent by the VF will not carry the same source MAC
> > address as the non-CM packets.
> >
> > Earlier 3.15-rc commit f24f790 "net/mlx4_core: Load the Eth driver
> > first" handled just one instance of the problem, but this one
> > provides a more generic and proper solution which covers all
> > cases of VF mac change.
> >
> > Matan and Or.
>
> Do you guys want this to go via my 'net' tree or via Roland's
> 'infiniband' tree?


net, since the relevant feature went into 3.15-rc1 through net-next
