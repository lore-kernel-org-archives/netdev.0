From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [Patch net] bonding: use ETH_MAX_MTU as max mtu
Date: Mon, 6 Mar 2017 08:49:35 -0500
Message-ID: <5b81bf8a-4d26-84ac-bd2a-533b1f2a9e24@redhat.com>
References: <1488486276-24552-1-git-send-email-xiyou.wangcong@gmail.com>
 <c215a583-0433-d087-be34-e90adc05ac43@redhat.com>
 <20170306134048.GC1822@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        daznis@gmail.com, lists2009@fnarfbargle.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43806 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752974AbdCFN5o (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Mar 2017 08:57:44 -0500
In-Reply-To: <20170306134048.GC1822@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-03-06 8:40 AM, Jiri Pirko wrote:
> Mon, Mar 06, 2017 at 02:36:47PM CET, jarod@redhat.com wrote:
>> On 2017-03-02 3:24 PM, Cong Wang wrote:
>>> This restores the ability of setting bond device's mtu to 9000.
>>>
>>> Fixes: 91572088e3fd ("net: use core MTU range checking in core net infra")
>>> Reported-by: daznis@gmail.com
>>> Reported-by: Brad Campbell <lists2009@fnarfbargle.com>
>>> Cc: Jarod Wilson <jarod@redhat.com>
>>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>>
>> Apologies, I'm a bit late to the party, direct CC didn't land in inbox
>> because of duplicate suppression or perhaps a greedy mail filtering rule
>> (*grumble*)... Too late to ack, but yeah, that's necessary. I *think* the
>> team driver may also require the same treatment. It calls ether_setup()
>> without anything setting max_mtu as well.
>
> Jarod, could you please send the fix? Thanks.

Done.

-- 
Jarod Wilson
jarod@redhat.com
