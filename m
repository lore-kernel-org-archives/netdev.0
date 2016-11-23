From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] cpsw: ethtool: add support for getting/setting EEE
 registers
Date: Wed, 23 Nov 2016 12:15:46 -0800
Message-ID: <c91dcd74-3983-3ab6-91f6-3657b1e601af@gmail.com>
References: <1479911913-1761-1-git-send-email-yegorslists@googlemail.com>
 <93e0bd06-3171-e12b-b763-1e2895a463f8@gmail.com>
 <CAGm1_ksC_6afhzK39uVTSk2PoC9CrR4Fow89YCZfihS2f6wzOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        "N, Mugunthan V" <mugunthanvnm@ti.com>,
        Rami Rosen <roszenrami@gmail.com>
To: Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33217 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936216AbcKWUPt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 15:15:49 -0500
In-Reply-To: <CAGm1_ksC_6afhzK39uVTSk2PoC9CrR4Fow89YCZfihS2f6wzOw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/23/2016 12:08 PM, Yegor Yefremov wrote:
> On Wed, Nov 23, 2016 at 6:33 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> On 11/23/2016 06:38 AM, yegorslists@googlemail.com wrote:
>>> From: Yegor Yefremov <yegorslists@googlemail.com>
>>>
>>> Add the ability to query and set Energy Efficient Ethernet parameters
>>> via ethtool for applicable devices.
>>
>> Are you sure this is enough to actually enable EEE? I don't see where
>> phy_init_eee() is called here, nor is the cpsw Ethernet controller part
>> configured to enable/disable EEE. EEE is not just a PHY thing, it
>> usually also needs to be configured properly at the Ethernet MAC/switch
>> level as well.
>>
>> Just curious here.
> 
> I'm sure I want to disable EEE :-) So I need this patch in order to
> check and disable EEE advertising.

OK, so you need this to disable EEE advertisement, which is great, but
this also allows you to enable EEE, is it enough to just advertise EEE
with your link partner for cpsw to work correctly? Just wondering, since
your commit message is more than short.
-- 
Florian
