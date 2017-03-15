From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 01/13] i40evf: fix client warnings
Date: Tue, 14 Mar 2017 17:49:23 -0700 (PDT)
Message-ID: <20170314.174923.974483463165642370.davem@davemloft.net>
References: <20170314223308.53451-2-jeffrey.t.kirsher@intel.com>
        <20170314.173949.1164218813681950110.davem@davemloft.net>
        <1489538684.3541.22.camel@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: faisal.latif@intel.com, netdev@vger.kernel.org, nhorman@redhat.com,
        sassmann@redhat.com, jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58704 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751207AbdCOAtZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 20:49:25 -0400
In-Reply-To: <1489538684.3541.22.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 14 Mar 2017 17:44:44 -0700

> On Tue, 2017-03-14 at 17:39 -0700, David Miller wrote:
>> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> Date: Tue, 14 Mar 2017 15:32:56 -0700
>> 
>> > From: Faisal Latif <faisal.latif@intel.com>
>> > 
>> > The function prototype in i40evf_client.h are giving warnings while
>> > compiling i40iwvf module. Move these function prototypes to
>> > i40evf.h.
>> > Also fix return code from u32 to int and this return code is
>> > consistent with i40e_client.h
>> > 
>> > Change-Id: Ie3757f844993aabc27654aaf02ec14fb985ad2c4
>> > Signed-off-by: Faisal Latif <faisal.latif@intel.com>
>> > Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
>> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> 
>> There is no such i40evf_client.h header file in the tree.
> 
> Not sure how this got out of order, Mitch adds this file in patch #4

Ok, please fix the order so that the dependencies are correct.

Thanks.
