From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [Patch net] bonding: use ETH_MAX_MTU as max mtu
Date: Mon, 6 Mar 2017 14:40:48 +0100
Message-ID: <20170306134048.GC1822@nanopsycho.orion>
References: <1488486276-24552-1-git-send-email-xiyou.wangcong@gmail.com>
 <c215a583-0433-d087-be34-e90adc05ac43@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        daznis@gmail.com, lists2009@fnarfbargle.com
To: Jarod Wilson <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33775 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754026AbdCFOHx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 09:07:53 -0500
Received: by mail-wm0-f66.google.com with SMTP id n11so13938593wma.0
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 06:06:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <c215a583-0433-d087-be34-e90adc05ac43@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 06, 2017 at 02:36:47PM CET, jarod@redhat.com wrote:
>On 2017-03-02 3:24 PM, Cong Wang wrote:
>> This restores the ability of setting bond device's mtu to 9000.
>> 
>> Fixes: 91572088e3fd ("net: use core MTU range checking in core net infra")
>> Reported-by: daznis@gmail.com
>> Reported-by: Brad Campbell <lists2009@fnarfbargle.com>
>> Cc: Jarod Wilson <jarod@redhat.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>
>Apologies, I'm a bit late to the party, direct CC didn't land in inbox
>because of duplicate suppression or perhaps a greedy mail filtering rule
>(*grumble*)... Too late to ack, but yeah, that's necessary. I *think* the
>team driver may also require the same treatment. It calls ether_setup()
>without anything setting max_mtu as well.

Jarod, could you please send the fix? Thanks.
