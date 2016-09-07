From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 1/2] fib: introduce fib notification
 infrastructure
Date: Wed, 7 Sep 2016 10:03:02 +0200
Message-ID: <20160907080302.GA1964@nanopsycho>
References: <1473163300-2045-1-git-send-email-jiri@resnulli.us>
 <1473163300-2045-2-git-send-email-jiri@resnulli.us>
 <e004cc9f-d9ac-3368-4045-db5a0f59347b@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, linville@tuxdriver.com, tgraf@suug.ch,
        gospo@cumulusnetworks.com, sfeldma@gmail.com, ast@plumgrid.com,
        edumazet@google.com, hannes@stressinduktion.org,
        f.fainelli@gmail.com, jhs@mojatatu.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@intel.com,
        andrew@lunn.ch, ivecera@redhat.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:33228 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932305AbcIGIDG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 04:03:06 -0400
Received: by mail-wm0-f41.google.com with SMTP id w12so17702870wmf.0
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 01:03:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <e004cc9f-d9ac-3368-4045-db5a0f59347b@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Sep 06, 2016 at 05:13:36PM CEST, dsa@cumulusnetworks.com wrote:
>On 9/6/16 6:01 AM, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> This allows to pass information about added/deleted fib entries to
>> whoever is interested. This is done in a very similar way as devinet
>> notifies address additions/removals.
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  include/net/ip_fib.h | 19 +++++++++++++++++++
>>  net/ipv4/fib_trie.c  | 43 +++++++++++++++++++++++++++++++++++++++++++
>>  2 files changed, 62 insertions(+)
>
>Do you intend for this set of notifiers to work with policy routing (FIB rules) as well?


Yes, plan is to put the notifier calls before notify_rule_change. Would
probably make sense to have this in one notifier, only several event
types. Not sure.
