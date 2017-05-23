From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2 v2 repost 1/3] tc_filter: add support for chain
 index
Date: Tue, 23 May 2017 15:40:42 +0200
Message-ID: <20170523134042.GC1829@nanopsycho>
References: <20170516172802.1317-1-jiri@resnulli.us>
 <20170516172937.1391-1-jiri@resnulli.us>
 <20170522133315.3490fe0a@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, dsa@cumulusnetworks.com,
        edumazet@google.com, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, simon.horman@netronome.com,
        mlxsw@mellanox.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36065 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967784AbdEWNkq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 09:40:46 -0400
Received: by mail-wm0-f65.google.com with SMTP id k15so38280456wmh.3
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 06:40:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170522133315.3490fe0a@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, May 22, 2017 at 10:33:15PM CEST, stephen@networkplumber.org wrote:
>On Tue, 16 May 2017 19:29:35 +0200
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Allow user to put filter to a specific chain identified by index.
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>
>Applied to net-next branch of iproute2

Looks like you missed the uapi part:

    CC       tc_filter.o
tc_filter.c: In function ‘tc_filter_modify’:
tc_filter.c:159:34: error: ‘TCA_CHAIN’ undeclared (first use in this function)
   addattr32(&req.n, sizeof(req), TCA_CHAIN, chain_index);
                                  ^~~~~~~~~
