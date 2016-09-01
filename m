From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH] e1000: add initial XDP support
Date: Thu, 1 Sep 2016 12:33:13 -0700
Message-ID: <57C88279.4030701@gmail.com>
References: <20160827071145.25345.84712.stgit@john-Precision-Tower-5810>
 <b6cfb3c5-9c68-3ea7-48dd-7fbf666db751@mojatatu.com>
 <20160829103047.3968a4d8@redhat.com>
 <61de1b91-30b4-67ba-4192-834fa30757ea@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: bblanco@plumgrid.com, davem@davemloft.net,
        alexei.starovoitov@gmail.com, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36821 "EHLO
        mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757297AbcIAVTa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 17:19:30 -0400
Received: by mail-pa0-f43.google.com with SMTP id fu3so25552698pad.3
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 14:19:29 -0700 (PDT)
In-Reply-To: <61de1b91-30b4-67ba-4192-834fa30757ea@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

> I think given how ancient the e1000 is we may see the driver being
> a contributing overhead. I believe XDP given location will do
> well - but for this kind of driver my gut feeling is probably not
> by large margin.
> 

Right so just ran the baseline, xdp, tc spread and its all more or
less in the noise where you drop the packets doesn't matter much. At
least in my setup where I'm running e1000 in a VM backed by a tap
device. I don't have a physical e1000 in my system at the moment to
test.

I still think this code is valuable though because it lets me run
the same XDP program in a e1000 VM that I'm running on my 10/40Gbps
NIC. Also it gives me a nice test platform to work on.

I'm going to resubmit the patch with a couple of the fixes pointed out
by others.

Thanks,
John
