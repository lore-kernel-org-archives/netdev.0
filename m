From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v10] openvswitch: enable NSH support
Date: Tue, 26 Sep 2017 16:42:40 +0200
Message-ID: <20170926164240.764a66ed@griffin>
References: <1506401236-5716-1-git-send-email-yi.y.yang@intel.com>
        <20170926130534.170270e3@griffin>
        <20170926135240.GA88616@cran64.bj.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "e@erig.me" <e@erig.me>,
        "davem@davemloft.net" <davem@davemloft.net>
To: "Yang, Yi" <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44068 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966816AbdIZOmo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 10:42:44 -0400
In-Reply-To: <20170926135240.GA88616@cran64.bj.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Sep 2017 21:52:41 +0800, Yang, Yi wrote:
> > +	return ((ret != 0) ? false : true);
> 
> But I don't think this is a problematic line from my understanding,

Why not:

	return ((ret != 0 == true) ? false : true) == true;

?

Sigh. This is equal to:

	return !ret;

which you should use.

 Jiri
