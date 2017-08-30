From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 0/4] nsh: headers, GSO
Date: Wed, 30 Aug 2017 09:44:58 +0200
Message-ID: <20170830094458.5564ec0b@griffin>
References: <cover.1503948295.git.jbenc@redhat.com>
        <20170829.151707.1911972805135395713.davem@davemloft.net>
        <20170830052303.GA109175@cran64.bj.intel.com>
        <20170830092040.61e5f09b@griffin>
        <20170830071936.GA111152@cran64.bj.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "e@erig.me" <e@erig.me>,
        "jan.scheurich@ericsson.com" <jan.scheurich@ericsson.com>,
        "blp@ovn.org" <blp@ovn.org>
To: "Yang, Yi" <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34812 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751186AbdH3HpC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Aug 2017 03:45:02 -0400
In-Reply-To: <20170830071936.GA111152@cran64.bj.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Aug 2017 15:19:37 +0800, Yang, Yi wrote:
> Do you mean we need move push_nsh from net/openvswitch/actions.c to
> net/nsh/nsh.c in order that kernel can load nsh kernel module
> automatically?

Yes. Without that struct sw_flow_key parameter but that's obvious.

 Jiri
