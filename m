From: David VomLehn <vomlehn@texas.net>
Subject: Re: [PATCH v7 00/13] net: ethernet: aquantia: Add AQtion 2.5/5 GB NIC
 driver
Date: Thu, 19 Jan 2017 14:45:00 -0800
Message-ID: <4e7c386f-e0bd-7647-ee2d-0afdcc9e6a91@texas.net>
References: <cover.1484860589.git.vomlehn@texas.net>
 <13303162-471c-de9c-a222-6bdbf5f38db9@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda6.aus1.datafoundry.com ([209.99.124.137]:47687 "EHLO
        milter.aus.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751583AbdASWpt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 17:45:49 -0500
In-Reply-To: <13303162-471c-de9c-a222-6bdbf5f38db9@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/19/2017 02:41 PM, Florian Fainelli wrote:
> On 01/19/2017 01:33 PM, Alexander Loktionov wrote:
>> From: David VomLehn <vomlehn@texas.net>
>>
>> This series introduces the AQtion NIC driver for the aQuantia
>> AQC107/AQC108 network devices.
>> v5: o Removed extra newline at the end of the files.
>> v6: o Removed unnecessary cast from void*.
>>      o Reworked strings array for ethtool statistics.
>>      o Added stringset == ETH_SS_STATS checking.
>>      o AQ_OBJ_HEADER replaced to aq_obj_header_s struct.
>>      o AQ_OBJ_SET/TST/CLR macroses replaced to inline functions.
>>      o Driver sources placed in to atlantic directory.
>>      o Fixed compilation warnings (Make W=1)
>>      o Added firmware version checking.
>>      o Code cleaning.
>> v7  o Removed unnecessary cast from memory allocation function (aq_ring.c).
> In general, you may want for a couple of days before resubmitting new
> versions that only fix minor stuff like what happened here between v6
> and v7.
Yeah, the number of comments has dropped enough that I had hopes this 
last one might be it. It makes me, I know, a foolish dreamer, but such 
is the lot of a software developer...

-- 
David VL
