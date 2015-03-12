From: Hadar Hen Zion <hadarh@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V1 0/3] net/mlx4_core: Allow setting init-time
 device specific parameters
Date: Thu, 12 Mar 2015 10:07:35 +0200
Message-ID: <CAJL1qvHP0cLRVf53J9MuJrYCJLjE=mzEU70JofJ8zH_Yf-O16g@mail.gmail.com>
References: <1426064933-29072-1-git-send-email-amirv@mellanox.com>
	<20150311.131457.1314699780103858026.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Vadai <amirv@mellanox.com>, netdev <netdev@vger.kernel.org>,
	Hadar Hen Zion <hadarh@mellanox.com>, yevgenyp@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>, shannon.nelson@intel.com,
	dledford@redhat.com, greearb@candelatech.com,
	gregory.v.rose@intel.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com
To: David Miller <davem@davemloft.net>, gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:34288 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753525AbbCLIHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 04:07:36 -0400
Received: by iecsl2 with SMTP id sl2so24962252iec.1
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 01:07:35 -0700 (PDT)
In-Reply-To: <20150311.131457.1314699780103858026.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2015 at 7:14 PM, David Miller <davem@davemloft.net> wrote:
>
> From: Amir Vadai <amirv@mellanox.com>
> Date: Wed, 11 Mar 2015 11:08:50 +0200
>
> > Also, customers are paying for a very sophisticated piece of
> > hardware, and we would like to enable power user to tweak it in some
> > situtations. Of course the default mode should be used in 99% of the
> > use cases.
>
> How much money someone pays for your hardware has nothing to do with
> the standards by which we design userspace interfaces to configure
> these devices.
>
> These textual interfaces are arbitrary, and you are choosing it only
> because you cannot come up with a more reasonable scheme,
>
> I'm not applying these changes.
> --

In previous conversations Greg suggested us to use configfs.

Is this case a misuse of configfs?  maybe configfs should be deprecated... Greg?

Is a scheme based on netlink will be acceptable by you?

Thanks,

Hadar and Amir
