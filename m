From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH RFC, iproute2] tc/mqprio: Add support to configure
 bandwidth rate limit through mqprio
Date: Tue, 18 Jul 2017 17:29:35 -0700
Message-ID: <20170718172935.6426dc6c@xeon-e3>
References: <150008197300.6559.15065389482024982399.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@intel.com,
        kiran.patil@intel.com, sridhar.samudrala@intel.com,
        mitch.a.williams@intel.com, alexander.duyck@gmail.com,
        neerav.parikh@intel.com, carolyn.wyborny@intel.com,
        jeffrey.t.kirsher@intel.com
To: Amritha Nambiar <amritha.nambiar@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33815 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751560AbdGSAcr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 20:32:47 -0400
Received: by mail-pf0-f171.google.com with SMTP id q85so18924994pfq.1
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 17:32:47 -0700 (PDT)
In-Reply-To: <150008197300.6559.15065389482024982399.stgit@anamdev.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Jul 2017 18:26:13 -0700
Amritha Nambiar <amritha.nambiar@intel.com> wrote:

> Support bandwidth rate limit information for a traffic
> class in addition to the number of TCs and associated
> queue configuration data. This is supported in the new
> hardware offload mode in mqprio by setting the value of
> 'hw' option to 2. This new hardware offload mode in mqprio
> makes full use of the mqprio options, the TCs, the
> queue configurations and the bandwidth rates for the TCs.
> 
> # tc qdisc add dev eth0 root mqprio num_tc 2  map 0 0 0 0 1 1 1 1\
>   queues 4@0 4@4 min_rate 0Mbit 0Mbit max_rate 55Mbit 60Mbit hw 2
> 
> # tc qdisc show dev eth0
> 
> qdisc mqprio 804a: root  tc 2 map 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0
>              queues:(0:3) (4:7)
>              min rates:0bit 0bit
>              max rates:55Mbit 60Mbit
> 
> Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>

As Jamal said, the syntax is awquard.
Also, for iproute2 commands the output format should match the input format
