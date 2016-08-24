From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: A second case of XPS considerably reducing single-stream
 performance
Date: Wed, 24 Aug 2016 16:46:22 -0700
Message-ID: <a661ff61-9cf8-fe86-ca20-2181394e1dbb@hpe.com>
References: <549357ea-dfda-284b-cdd6-4408060f9ca8@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@broadcom.com, ajit.khaparde@broadcom.com,
        sriharsha.basavapatna@broadcom.com, somnath.kotur@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hpe.com ([15.233.16.89]:56278 "EHLO
        g2t1383g.austin.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751506AbcHYFEr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 01:04:47 -0400
Received: from g9t5009.houston.hpe.com (g9t5009.houston.hpe.com [15.241.48.73])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by g2t1383g.austin.hpe.com (Postfix) with ESMTPS id 341582767
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 23:46:24 +0000 (UTC)
In-Reply-To: <549357ea-dfda-284b-cdd6-4408060f9ca8@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also, while it doesn't seem to have the same massive effect on 
throughput, I can also see out of order behaviour happening when the 
sending VM is on a node with a ConnectX-3 Pro NIC.  Its driver is also 
enabling XPS it would seem.  I'm not *certain* but looking at the traces 
it appears that with the ConnectX-3 Pro there is more interleaving of 
the out-of-order traffic than there is with the Skyhawk.  The ConnectX-3 
Pro happens to be in a newer generation server with a newer processor 
than the other systems where I've seen this.

I do not see the out-of-order behaviour when the NIC at the sending end 
is a BCM57840.  It does not appear that the bnx2x driver in the 4.4 
kernel is enabling XPS.

So, it would seem that there are three cases of enabling XPS resulting 
in out-of-order traffic, two of which result in a non-trivial loss of 
performance.

happy benchmarking,

rick jones
