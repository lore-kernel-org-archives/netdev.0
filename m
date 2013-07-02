From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next 0/2] net/mlx4: Add dynamic policy changes to the
 SRIOV eSwitch support
Date: Tue, 2 Jul 2013 07:40:21 +0300
Message-ID: <CAJZOPZ+f7Z6kbtEGvsVWd6G0JEYanTHKLfRKuLbrg29jS2+OVg@mail.gmail.com>
References: <1372349122-23390-1-git-send-email-ogerlitz@mellanox.com>
	<20130701.131255.894732078933976198.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: ogerlitz@mellanox.com, netdev@vger.kernel.org,
	jackm@dev.mellanox.co.il, ronye@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f43.google.com ([209.85.216.43]:57877 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832Ab3GBEkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 00:40:21 -0400
Received: by mail-qa0-f43.google.com with SMTP id d13so2586546qak.16
        for <netdev@vger.kernel.org>; Mon, 01 Jul 2013 21:40:21 -0700 (PDT)
In-Reply-To: <20130701.131255.894732078933976198.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 1, 2013 at 11:12 PM, David Miller <davem@davemloft.net> wrote:
>
> From: Or Gerlitz <ogerlitz@mellanox.com>
> Date: Thu, 27 Jun 2013 19:05:20 +0300
>
> > This patch set from Jack and Rony uses the UPDATE_QP new firmware
> > command
> > to allow for dynamic policy changes of PF controlled VF vlan/qos and
> > link-state.
> >
> > Done against net-next commit 8599b52e14 "bonding: add an option to fail
> > when any
> > of arp_ip_target is inaccessible"
>
> Applied, but in patch #2:
>
> +               /* even if the UPDATE_QP command isn't supported, we still want
> +                * to set this VF link according to the admin directive
> +                */
>
> Those last two lines start with a space, then TAB(s), which I had to
> fix up.  GIT even warns about this when I apply your patches.

thanks, last time similar thing happened I said that next time I will
double check, so I probably need to move into triple checking... I
will do little investigation later today to see how come there were no
complaints on my system.
