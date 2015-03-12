From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH net-next V1 0/3] net/mlx4_core: Allow setting init-time
 device specific parameters
Date: Thu, 12 Mar 2015 14:46:51 +0100
Message-ID: <20150312134651.GB32053@kroah.com>
References: <1426064933-29072-1-git-send-email-amirv@mellanox.com>
 <20150311.131457.1314699780103858026.davem@davemloft.net>
 <CAJL1qvHP0cLRVf53J9MuJrYCJLjE=mzEU70JofJ8zH_Yf-O16g@mail.gmail.com>
 <20150312090042.GB1092@kroah.com>
 <5501803D.8020101@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hadar Hen Zion <hadarh@dev.mellanox.co.il>,
	David Miller <davem@davemloft.net>,
	Amir Vadai <amirv@mellanox.com>,
	netdev <netdev@vger.kernel.org>,
	Hadar Hen Zion <hadarh@mellanox.com>, yevgenyp@mellanox.com,
	Tal Alon <talal@mellanox.com>, shannon.nelson@intel.com,
	dledford@redhat.com, greearb@candelatech.com,
	gregory.v.rose@intel.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:36458 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754555AbbCLNqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 09:46:55 -0400
Content-Disposition: inline
In-Reply-To: <5501803D.8020101@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2015 at 02:02:05PM +0200, Or Gerlitz wrote:
> On 3/12/2015 11:00 AM, Greg KH wrote:
> >On Thu, Mar 12, 2015 at 10:07:35AM +0200, Hadar Hen Zion wrote:
> >>On Wed, Mar 11, 2015 at 7:14 PM, David Miller <davem@davemloft.net> wrote:
> >>>From: Amir Vadai <amirv@mellanox.com>
> >>>Date: Wed, 11 Mar 2015 11:08:50 +0200
> >>>
> >>>>Also, customers are paying for a very sophisticated piece of hardware, and we would like to enable power user to tweak it in some situtations. Of course the default mode should be used in 99% of the use cases.
> >>>How much money someone pays for your hardware has nothing to do with the standards by which we design userspace interfaces to configure these devices.
> >>>
> >>>These textual interfaces are arbitrary, and you are choosing it only because you cannot come up with a more reasonable scheme,
> >>>
> >>>I'm not applying these changes.
> >>>---
> >>In previous conversations Greg suggested us to use configfs.
> >>
> >>Is this case a misuse of configfs? maybe configfs should be deprecated... Greg?
> >No, this has nothing to do with the validity of configfs, please re-read what David said to you.
> 
> Greg,
> 
> So.. M2-- reading Dave's words I understand that he's against textual
> interfacessuch as configfs and prefers others. This brings two questions to
> the table (1) do we need to deprecate these textual interfaces / configfs
> and avoid using them for configuration purposes with new code?

No, configfs works quite well for a number of other kernel subsystems,
so please leave them alone here.

> (2) does
> programmable interface such as netlink is the way to go for our purposes
> here (and elsewhere)?

I don't know, that's up to the network developers, but you had better
not abuse the firmware download inteface, that's what I strongly
objected to originally.

good luck,

greg k-h
