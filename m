From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 2/5] virtio_net: factor out xdp handler for
 readability
Date: Thu, 2 Feb 2017 18:52:33 -0800
Message-ID: <5893F071.9090104@gmail.com>
References: <20170202231404.14366.64298.stgit@john-Precision-Tower-5810>
 <20170202232052.14366.25904.stgit@john-Precision-Tower-5810>
 <20170202170548.74c9d1e3@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, ast@fb.com, mst@redhat.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34083 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751771AbdBCCwq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 21:52:46 -0500
Received: by mail-pg0-f67.google.com with SMTP id v184so657508pgv.1
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 18:52:46 -0800 (PST)
In-Reply-To: <20170202170548.74c9d1e3@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-02-02 05:05 PM, Jakub Kicinski wrote:
> On Thu, 02 Feb 2017 15:20:52 -0800, John Fastabend wrote:
>> At this point the do_xdp_prog is mostly if/else branches handling
>> the different modes of virtio_net. So remove it and handle running
>> the program in the per mode handlers.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> 
> I think you rebased away Daniel's tracepoints here :(
> 

Ah dang yep. Thanks for spotting.
