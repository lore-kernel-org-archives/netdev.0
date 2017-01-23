From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [RFC PATCH net-next 0/5] bridge: per vlan lwt and dst_metadata
 support
Date: Mon, 23 Jan 2017 17:24:58 +0100
Message-ID: <20170123172458.5c849171@griffin>
References: <1484977616-1541-1-git-send-email-roopa@cumulusnetworks.com>
        <20170123080805.GB1831@nanopsycho.orion>
        <20170123095130.59ddcf34@griffin>
        <58862BAA.4060001@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, stephen@networkplumber.org,
        nikolay@cumulusnetworks.com, tgraf@suug.ch,
        hannes@stressinduktion.org, pshelar@ovn.org,
        dsa@cumulusnetworks.com, hadi@mojatatu.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43146 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750723AbdAWQZE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 11:25:04 -0500
In-Reply-To: <58862BAA.4060001@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Jan 2017 08:13:30 -0800, Roopa Prabhu wrote:
> And, a 'vlan-to-tunid' mapping is a very common configuration in L2 ethernet vpn configurations.

You have one particular and narrow use case in mind and are proposing a
rather large patchset to add support for that (and only that) single
use case, while we already have a generic mechanism in place to address
this and many similar (and dissimilar, too) use cases. That doesn't
sound right.

If the current generic mechanisms have bottlenecks for your use case,
let's work on removing those bottlenecks. That way, everybody benefits,
not just a single use case.

Thanks,

 Jiri
