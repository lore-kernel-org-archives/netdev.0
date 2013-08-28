From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v1 5/9] bonding: convert bond_has_this_ip() to
 use upper devices
Date: Wed, 28 Aug 2013 14:00:24 +0200
Message-ID: <20130828120024.GH1992@redhat.com>
References: <1377549162-7522-1-git-send-email-vfalico@redhat.com>
 <1377549162-7522-6-git-send-email-vfalico@redhat.com>
 <20130826205338.GA3723@minipsycho.orion>
 <20130827111648.GB24836@redhat.com>
 <20130827112529.GA4732@minipsycho.brq.redhat.com>
 <20130827181001.GD24836@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63987 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752675Ab3H1MBm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 08:01:42 -0400
Content-Disposition: inline
In-Reply-To: <20130827181001.GD24836@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 27, 2013 at 08:10:01PM +0200, Veaceslav Falico wrote:
...snip...
>3) Adding lower_dev_list, populating it accordingly, and also adding an int
>distance to the netdev_upper (or, with this approach, rather netdev_adjacent
>or something like that), which will help to implement your idea - a device
>will have lower/upper_dev_list populated with all lower/upper devices and
>their distance (i.e. distance == 1 means that it's first level of
>lower/upper device). With this approach, we might also afterwards get rid
>of slave lists from 'grouping' devices like bonding/team/bridge/etc. and,
>thus, the locking.

Just FYI, I've taken this approach in the next version, seems to (suddenly)
work fine, FWIW...

I'll send the v2 in few minutes.

Thanks again!
