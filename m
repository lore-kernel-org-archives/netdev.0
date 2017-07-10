From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH iproute2 V3 0/4] RDMAtool
Date: Mon, 10 Jul 2017 20:29:31 +0200
Message-ID: <20170710182931.GG1853@nanopsycho>
References: <20170704075541.12544-1-leon@kernel.org>
 <20170710080230.GD1853@nanopsycho>
 <20170710160144.GN1528@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Doug Ledford <dledford@redhat.com>,
        Ariel Almog <ariela@mellanox.com>,
        Linux RDMA <linux-rdma@vger.kernel.org>,
        Linux Netdev <netdev@vger.kernel.org>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33660 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752509AbdGJS3e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 14:29:34 -0400
Received: by mail-wr0-f196.google.com with SMTP id x23so26757148wrb.0
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 11:29:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170710160144.GN1528@mtr-leonro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jul 10, 2017 at 06:01:44PM CEST, leon@kernel.org wrote:
>On Mon, Jul 10, 2017 at 10:02:30AM +0200, Jiri Pirko wrote:
>> Tue, Jul 04, 2017 at 09:55:37AM CEST, leon@kernel.org wrote:
>> >Hi,
>> >
>> >This is third version of series implementing the RDAMtool -  the tool
>> >to configure RDMA devices. The initial proposal was sent as RFC [1] and
>> >was based on sysfs entries as POC.
>> >
>> >The current series was rewritten completely to work with RDMA netlinks as
>> >a source of user<->kernel communications. In order to achieve that, the
>> >RDMA netlinks were extensively refactored and modernized [2, 3, 4 and 5].
>> >
>> >The following is an example of various runs on my machine with 5 devices
>> >(4 in IB mode and one in Ethernet mode)
>> >
>> >### Without parameters
>> >$ rdma
>> >Usage: rdma [ OPTIONS ] OBJECT { COMMAND | help }
>> >where  OBJECT := { dev | link | help }
>> >       OPTIONS := { -V[ersion] | -d[etails]}
>>
>> What about json output? You will need it sooner than later. It will
>> prevent you from a lot of headaches if you implement it right away.
>> Lesson learned...
>
>I'm planning to do it in the coming kernel cycle.

Yeah, just consider pushing it in this initial patchset. Makes sense and
saves you troubles. Up to you.
