From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2 v2 repost 2/3] tc: actions: add helpers to parse
 and print control actions
Date: Wed, 14 Jun 2017 21:18:50 +0200
Message-ID: <20170614191850.GA1972@nanopsycho>
References: <20170516172802.1317-1-jiri@resnulli.us>
 <20170516172937.1391-2-jiri@resnulli.us>
 <20170614203222.3dcc183d@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, dsa@cumulusnetworks.com,
        edumazet@google.com, stephen@networkplumber.org,
        daniel@iogearbox.net, alexander.h.duyck@intel.com,
        simon.horman@netronome.com, mlxsw@mellanox.com
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36139 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751628AbdFNTTM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 15:19:12 -0400
Received: by mail-wr0-f193.google.com with SMTP id 77so2375428wrb.3
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 12:19:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170614203222.3dcc183d@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jun 14, 2017 at 08:32:22PM CEST, jbenc@redhat.com wrote:
>On Tue, 16 May 2017 19:29:36 +0200, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Each tc action is terminated by a control action. Each action parses and
>> prints then intividually. Introduce set of helpers and allow to share
>> this code.
>
>This patch, as indicated by git bisect, broke tc if there are multiple
>actions specified. This somehow non-real life reproducer (the real case
>where this broke for me was more complex) works fine with 732f03461bc4:
>
># tc filter add dev eth0 parent 1: matchall action vlan push id 1 action drop
>
>while with both the current net-next and with e67aba559581, the result
>is:
>
># tc filter add dev eth0 parent 1: matchall action vlan push id 1 action drop
>Bad action type action

Isn't it fixed by:

https://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git/commit/?h=net-next&id=18f05d06016d9492c87fd105d831de0d6d858f43

?

I will try this tomorrow
