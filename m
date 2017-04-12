From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next v5 1/5] netlink: extended ACK reporting
Date: Wed, 12 Apr 2017 17:21:43 +0200
Message-ID: <1492010503.2855.14.camel@sipsolutions.net>
References: <20170412123408.22012-1-johannes@sipsolutions.net>
         <20170412123408.22012-2-johannes@sipsolutions.net>
         <dbc81431-487b-f218-a4c6-2caa44783d97@cumulusnetworks.com>
         (sfid-20170412_170649_644527_0ED3DE34)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>, jiri@resnulli.us
To: David Ahern <dsa@cumulusnetworks.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:38184 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752513AbdDLPVr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 11:21:47 -0400
In-Reply-To: <dbc81431-487b-f218-a4c6-2caa44783d97@cumulusnetworks.com> (sfid-20170412_170649_644527_0ED3DE34)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-04-12 at 09:06 -0600, David Ahern wrote:
> 
> There was a discussion about side effects of adding strings (bloat,
> internationalization). Should ATTR_MSG be removed until that is
> ironed out? Leaving it in suggests it is ok to start adding strings.

I really do want the strings; this is why I named the struct member
"_msg" and added the NL_SET_ERR_MSG() macro, that will easily allow
both making the strings optional with Kconfig (bloat) and collecting
them into a separate data section (translation).

johannes
