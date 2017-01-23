From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [RFC PATCH net-next 0/5] bridge: per vlan lwt and dst_metadata
 support
Date: Mon, 23 Jan 2017 09:51:30 +0100
Message-ID: <20170123095130.59ddcf34@griffin>
References: <1484977616-1541-1-git-send-email-roopa@cumulusnetworks.com>
        <20170123080805.GB1831@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>, netdev@vger.kernel.org,
        davem@davemloft.net, stephen@networkplumber.org,
        nikolay@cumulusnetworks.com, tgraf@suug.ch,
        hannes@stressinduktion.org, pshelar@ovn.org,
        dsa@cumulusnetworks.com, hadi@mojatatu.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59718 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750703AbdAWIvh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 03:51:37 -0500
In-Reply-To: <20170123080805.GB1831@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Jan 2017 09:08:05 +0100, Jiri Pirko wrote:
> Sat, Jan 21, 2017 at 06:46:51AM CET, roopa@cumulusnetworks.com wrote:
> >Other approaches tried and vetoed:
> >- tc vlan push/pop and tunnel metadata dst:
> >    - posses a tc rule scalability problem (2 rules per vni)
> 
> Why it is a problem?

Wanted to ask exactly the same question.

> >    - cannot handle the case where a packet needs to be replicated to
> >      multiple vxlan remote tunnel end-points.. which the vxlan driver
> >      can do today by having multiple remote destinations per fdb.
> 
> Can't you just extend the tc to support this?

+1

> To me, looks like the tc is the correct place to hangle this. Then, the
> user can use it for multiple cases of forwarding, including bridge,
> tc-mirred, ovs and others. Putting this in bridge somehow seems wrong in
> this light. Also, the bridge code is polluted enough as it is. I this we
> should be super-picky to add another code there.

Completely agreed.

 Jiri
