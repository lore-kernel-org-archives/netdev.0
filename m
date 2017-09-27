From: "Yang, Yi" <yi.y.yang@intel.com>
Subject: Re: [PATCH net-next v10] openvswitch: enable NSH support
Date: Wed, 27 Sep 2017 08:52:19 +0800
Message-ID: <20170927005218.GA97665@cran64.bj.intel.com>
References: <1506401236-5716-1-git-send-email-yi.y.yang@intel.com>
 <20170926130534.170270e3@griffin>
 <20170926135240.GA88616@cran64.bj.intel.com>
 <20170926164240.764a66ed@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "e@erig.me" <e@erig.me>,
        "davem@davemloft.net" <davem@davemloft.net>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:30961 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1030330AbdI0BHc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 21:07:32 -0400
Content-Disposition: inline
In-Reply-To: <20170926164240.764a66ed@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 26, 2017 at 10:42:40PM +0800, Jiri Benc wrote:
> On Tue, 26 Sep 2017 21:52:41 +0800, Yang, Yi wrote:
> > > +	return ((ret != 0) ? false : true);
> > 
> > But I don't think this is a problematic line from my understanding,
> 
> Why not:
> 
> 	return ((ret != 0 == true) ? false : true) == true;
> 
> ?
> 
> Sigh. This is equal to:
> 
> 	return !ret;
> 
> which you should use.

Ok, got it, I'll use "return !ret;", real programming art :-), I also saw
!!(condition), personally its readability is not good, typical kernel
style :-)
