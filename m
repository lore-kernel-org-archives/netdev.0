From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/5] netlink: extended ACK reporting
Date: Mon, 10 Apr 2017 08:18:09 +0200
Message-ID: <1491805089.2455.3.camel@sipsolutions.net>
References: <20170408174900.12820-1-johannes@sipsolutions.net>
         <20170408174900.12820-2-johannes@sipsolutions.net>
         <20170408183440.GA1900@nanopsycho>
         <1491676621.5800.24.camel@sipsolutions.net>
         <20170408184008.GB1900@nanopsycho>
         <990b5610-a894-b3d2-d3a7-536dfd25adb8@cumulusnetworks.com>
         (sfid-20170409_194335_996479_352F2989)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        pablo@netfilter.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>
To: David Ahern <dsa@cumulusnetworks.com>,
        Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:33444 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750957AbdDJGSN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Apr 2017 02:18:13 -0400
In-Reply-To: <990b5610-a894-b3d2-d3a7-536dfd25adb8@cumulusnetworks.com> (sfid-20170409_194335_996479_352F2989)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> perhaps I misunderstand something, but nla_parse suggests attribute
> type can not be 0:
[...]

Yes, some - very few - families still insist on using attribute 0,
perhaps parsing by hand or so. Like you say though, the entire
infrastructure makes that hard and undesirable, so I don't really see
why we need to invest the extra code/work into making it work *here*,
especially since it's such a corner case as I described in my other
email.

johannes
