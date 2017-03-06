From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [Patch net] bonding: use ETH_MAX_MTU as max mtu
Date: Mon, 6 Mar 2017 08:36:47 -0500
Message-ID: <c215a583-0433-d087-be34-e90adc05ac43@redhat.com>
References: <1488486276-24552-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: daznis@gmail.com, lists2009@fnarfbargle.com,
        Jiri Pirko <jiri@resnulli.us>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42132 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753491AbdCFNpB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Mar 2017 08:45:01 -0500
In-Reply-To: <1488486276-24552-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-03-02 3:24 PM, Cong Wang wrote:
> This restores the ability of setting bond device's mtu to 9000.
>
> Fixes: 91572088e3fd ("net: use core MTU range checking in core net infra")
> Reported-by: daznis@gmail.com
> Reported-by: Brad Campbell <lists2009@fnarfbargle.com>
> Cc: Jarod Wilson <jarod@redhat.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Apologies, I'm a bit late to the party, direct CC didn't land in inbox 
because of duplicate suppression or perhaps a greedy mail filtering rule 
(*grumble*)... Too late to ack, but yeah, that's necessary. I *think* 
the team driver may also require the same treatment. It calls 
ether_setup() without anything setting max_mtu as well.

-- 
Jarod Wilson
jarod@redhat.com
