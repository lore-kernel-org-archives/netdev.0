From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH net-next V1 0/3] net/mlx4_core: Allow setting init-time
 device specific parameters
Date: Thu, 12 Mar 2015 10:00:42 +0100
Message-ID: <20150312090042.GB1092@kroah.com>
References: <1426064933-29072-1-git-send-email-amirv@mellanox.com>
 <20150311.131457.1314699780103858026.davem@davemloft.net>
 <CAJL1qvHP0cLRVf53J9MuJrYCJLjE=mzEU70JofJ8zH_Yf-O16g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Amir Vadai <amirv@mellanox.com>,
	netdev <netdev@vger.kernel.org>,
	Hadar Hen Zion <hadarh@mellanox.com>, yevgenyp@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>, shannon.nelson@intel.com,
	dledford@redhat.com, greearb@candelatech.com,
	gregory.v.rose@intel.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com
To: Hadar Hen Zion <hadarh@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:60830 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726AbbCLJAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 05:00:47 -0400
Content-Disposition: inline
In-Reply-To: <CAJL1qvHP0cLRVf53J9MuJrYCJLjE=mzEU70JofJ8zH_Yf-O16g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2015 at 10:07:35AM +0200, Hadar Hen Zion wrote:
> On Wed, Mar 11, 2015 at 7:14 PM, David Miller <davem@davemloft.net> wrote:
> >
> > From: Amir Vadai <amirv@mellanox.com>
> > Date: Wed, 11 Mar 2015 11:08:50 +0200
> >
> > > Also, customers are paying for a very sophisticated piece of
> > > hardware, and we would like to enable power user to tweak it in some
> > > situtations. Of course the default mode should be used in 99% of the
> > > use cases.
> >
> > How much money someone pays for your hardware has nothing to do with
> > the standards by which we design userspace interfaces to configure
> > these devices.
> >
> > These textual interfaces are arbitrary, and you are choosing it only
> > because you cannot come up with a more reasonable scheme,
> >
> > I'm not applying these changes.
> > --
> 
> In previous conversations Greg suggested us to use configfs.
> 
> Is this case a misuse of configfs?  maybe configfs should be deprecated... Greg?

No, this has nothing to do with the validity of configfs, please re-read
what David said to you.

greg k-h
