From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH v3 net-next 0/2] net: dsa: lan9303: Add fdb/mdb methods
Date: Fri, 20 Oct 2017 16:09:09 +0200
Message-ID: <4ef0c3c5-437d-ef37-4a9b-cb9c0b31ee56@egil-hjelmeland.no>
References: <20171020101910.2245-1-privat@egil-hjelmeland.no>
 <87d15h29y1.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aibo.runbox.com ([91.220.196.211]:48504 "EHLO aibo.runbox.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751585AbdJTOJs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 20 Oct 2017 10:09:48 -0400
In-Reply-To: <87d15h29y1.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20. okt. 2017 16:03, Vivien Didelot wrote:
> Hi Egil,
> 
> It looks much cleaner, thanks!
> 
> Egil Hjelmeland <privat@egil-hjelmeland.no> writes:
> 
>> This series add support for accessing and managing the lan9303 ALR
>> (Address Logic Resolution).
>>
>> The first patch add low level functions for accessing the ALR, along
>> with port_fast_age and port_fdb_dump methods.
>>
>> The second patch add functions for managing ALR entires, along with
>> remaining fdb/mdb methods.
>>
>> Note that to complete STP support, a special ALR entry with the STP eth
>> address must be added too. This must be addressed later.
>>
>> Comments welcome!
>>
>>
>> Changes v2 -> v3:
>>   - Whitespace polishing. Removed some "section" comments.
>>   - Prefixed ALR constants with LAN9303_ for consistency.
>>   - Patch 2: lan9303_port_fast_age() wrap the "port" into a struct for passing
>>     as context to alr_loop_cb_del_port_learned. Safer in event of type change.
>>   - Patch 2: Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> 
> You'll usually directly add the Reviewed-by: tags right under your
> Signed-off-by: tag of the concerned patches in next iterations.
> 

Oh, I thought I had done it, but now I see I forgot to rebuild the
patches after that last minute git-amend where I put in your
Reviewed-by:.

> (don't worry though I've added it back to patch 2/2.)
> 
> 
> Thanks,
> 
>          Vivien
> 

Egil
