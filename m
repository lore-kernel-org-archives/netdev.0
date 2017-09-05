From: "Yang, Yi" <yi.y.yang@intel.com>
Subject: Re: [PATCH net-next v7] openvswitch: enable NSH support
Date: Tue, 5 Sep 2017 19:03:11 +0800
Message-ID: <20170905110310.GB92895@cran64.bj.intel.com>
References: <1504096752-102003-1-git-send-email-yi.y.yang@intel.com>
 <20170831124516.0c5db686@griffin>
 <20170904080005.GA70767@cran64.bj.intel.com>
 <20170904124216.6db68e8c@griffin>
 <20170904120907.GA75461@cran64.bj.intel.com>
 <20170904145744.4d8b7fd5@griffin>
 <20170905055144.GA88800@cran64.bj.intel.com>
 <20170905114645.33bf0e32@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "e@erig.me" <e@erig.me>, "blp@ovn.org" <blp@ovn.org>,
        "jan.scheurich@ericsson.com" <jan.scheurich@ericsson.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:34421 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750755AbdIELSD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 5 Sep 2017 07:18:03 -0400
Content-Disposition: inline
In-Reply-To: <20170905114645.33bf0e32@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 05, 2017 at 11:46:45AM +0200, Jiri Benc wrote:
> On Tue, 5 Sep 2017 13:51:45 +0800, Yang, Yi wrote:
> > But if we follow your way, how does nla_for_each_nested handle such
> > pattern?
> > 
> > attribute1
> > attribute1_mask
> > attribute2
> > attribute2_mask
> > attribute3
> > attribute3_mask
> 
> Uh? That will just work. Note that nla len contains the size of the
> whole attribute, i.e. includes both fields.
> 
> > I don't think this can increase performance and readability.
>

I got the point, actually value and mask are data of one attribute, so
they are three attributes but not six. 
