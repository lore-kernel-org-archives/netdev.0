From: "Yang, Yi" <yi.y.yang@intel.com>
Subject: Re: [PATCH net-next 0/4] nsh: headers, GSO
Date: Wed, 30 Aug 2017 15:19:37 +0800
Message-ID: <20170830071936.GA111152@cran64.bj.intel.com>
References: <cover.1503948295.git.jbenc@redhat.com>
 <20170829.151707.1911972805135395713.davem@davemloft.net>
 <20170830052303.GA109175@cran64.bj.intel.com>
 <20170830092040.61e5f09b@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "e@erig.me" <e@erig.me>,
        "jan.scheurich@ericsson.com" <jan.scheurich@ericsson.com>,
        "blp@ovn.org" <blp@ovn.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:22001 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750983AbdH3He7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Aug 2017 03:34:59 -0400
Content-Disposition: inline
In-Reply-To: <20170830092040.61e5f09b@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 30, 2017 at 09:20:40AM +0200, Jiri Benc wrote:
> 
> > I'll post new OVS NSH kernel datapath patch series if NSH GSO is done.
> 
> Please do. Note that it's important to ensure that whenever there's a
> NSH header added, the nsh module gets loaded. The easiest way is to
> factor out code that will be shared by the NSH tc action into nsh.c.
> This would have to be done anyway so let's do it right away.

Do you mean we need move push_nsh from net/openvswitch/actions.c to
net/nsh/nsh.c in order that kernel can load nsh kernel module
automatically?

> 
>  Jiri
