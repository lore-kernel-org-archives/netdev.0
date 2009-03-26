From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3] igbvf: add new driver to support 82576
 virtual functions
Date: Wed, 25 Mar 2009 20:34:50 -0700 (PDT)
Message-ID: <20090325.203450.58187435.davem@davemloft.net>
References: <49CAD25F.4080705@intel.com>
	<20090325.201219.98810772.davem@davemloft.net>
	<5f2db9d90903252027n7079ca54v76c06ec3849c65d9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, shemminger@vyatta.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54258
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754869AbZCZDfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 23:35:02 -0400
In-Reply-To: <5f2db9d90903252027n7079ca54v76c06ec3849c65d9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 25 Mar 2009 20:27:28 -0700

> On Wed, Mar 25, 2009 at 8:12 PM, David Miller <davem@davemloft.net> wrote:
> > From: Alexander Duyck <alexander.h.duyck@intel.com>
> > Date: Wed, 25 Mar 2009 17:54:55 -0700
> >
> >> Since the issue isn't the igbvf driver there is no reason for it to
> >> be held up.
> >
> > I disagree, I think both cases should be fixed.
> >
> > Just because we do something already never means that it's
> > ok to proliferate the mistake further.
> 
> That isn't what I mean.  The code he is referring to exists nowhere in
> the igbvf driver.  I suppose I can edit the igbvf commit comments so
> that they don't mention the sysfs entry, but the code is in the igb
> driver.

I know it's in the igb driver, I fully understand that.

And I'm saying it was a mistake to merge that, it slipped past
me in my review of that change, and we need to move forward
and get rid of this thing.
