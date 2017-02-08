From: David Miller <davem@davemloft.net>
Subject: Re: [oss-drivers] Re: [PATCH/RFC net-next 1/2] flow dissector: ND
 support
Date: Wed, 08 Feb 2017 13:54:15 -0500 (EST)
Message-ID: <20170208.135415.601520734521006340.davem@davemloft.net>
References: <20170207.123831.1038511845714033360.davem@davemloft.net>
        <20170208092823.GA17615@penelope.horms.nl>
        <CALx6S36VrtQM5G2XPzpcrP=y3RyBwTnYJcaKqXtwyFgpGiz+Jg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: simon.horman@netronome.com, jiri@resnulli.us,
        eric.dumazet@gmail.com, dinan.gunawardena@netronome.com,
        netdev@vger.kernel.org, oss-drivers@netronome.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56734 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752412AbdBHTA4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 14:00:56 -0500
In-Reply-To: <CALx6S36VrtQM5G2XPzpcrP=y3RyBwTnYJcaKqXtwyFgpGiz+Jg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Wed, 8 Feb 2017 10:33:46 -0800

> On Wed, Feb 8, 2017 at 1:28 AM, Simon Horman <simon.horman@netronome.com> wrote:
>> I think the above paragraph gets back to Tom's original question regarding
>> making things more complex just for OvS (use-cases). Possibly ND is an edge
>> case even for OvS and on reflection my timing for posting it seems to have
>> been less than ideal.
> 
> If it wasn't ND it would be something else... with all the activity
> happening in networking features and HW this is a timely discussion.
> Flow dissector presents a good example of a function that might become
> a dumping ground for an endless stream of features if we don't figure
> out how exercise some restraint.

I agree on most points.

But, I would say that in this specific case, since we have ARP support in
there already it behooves us to support the ipv6 side in the form of ND
too.

Then we can put a line in the sand and say that future feature additions
in this area require serious discussion.

Ok Tom?
