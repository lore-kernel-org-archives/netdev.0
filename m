From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v7] openvswitch: enable NSH support
Date: Tue, 5 Sep 2017 11:49:49 +0200
Message-ID: <20170905114949.5849b75f@griffin>
References: <1504096752-102003-1-git-send-email-yi.y.yang@intel.com>
        <20170831124516.0c5db686@griffin>
        <20170904080005.GA70767@cran64.bj.intel.com>
        <20170904124216.6db68e8c@griffin>
        <CFF8EF42F1132E4CBE2BF0AB6C21C58D787F4E84@ESESSMB107.ericsson.se>
        <20170904151601.2f198a53@griffin>
        <CFF8EF42F1132E4CBE2BF0AB6C21C58D787F4EEB@ESESSMB107.ericsson.se>
        <20170904161303.69624386@griffin>
        <CFF8EF42F1132E4CBE2BF0AB6C21C58D787F4F69@ESESSMB107.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Yang, Yi" <yi.y.yang@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "e@erig.me" <e@erig.me>, "blp@ovn.org" <blp@ovn.org>
To: Jan Scheurich <jan.scheurich@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52992 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751017AbdIEJtx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 5 Sep 2017 05:49:53 -0400
In-Reply-To: <CFF8EF42F1132E4CBE2BF0AB6C21C58D787F4F69@ESESSMB107.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 4 Sep 2017 14:45:50 +0000, Jan Scheurich wrote:
> So what is the correct layout for MASKED_SET action with nested fields?
> 1. All nested values, followed by all nested masks, or
> 2. For each nested field value followed by mask?
> 
> I guess alternative 1, but just to be sure.

It's 2. Alternative 1 breaks netlink assumptions, is ugly to implement
and probably impossible to be properly validated.

 Jiri
