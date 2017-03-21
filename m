From: Jonas Bonn <jonas@southpole.se>
Subject: Re: [PATCH 1/1] gtp: support SGSN-side tunnels
Date: Tue, 21 Mar 2017 16:11:25 +0100
Message-ID: <3aee55f1-f42d-a0b5-5d50-b6bbea5ca74a@southpole.se>
References: <20170203091231.10142-1-jonas@southpole.se>
 <20170315163916.gins7lzzqhwkvfrc@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netdev@vger.kernel.org
To: Harald Welte <laforge@gnumonks.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([37.247.8.11]:38686 "EHLO mail.southpole.se"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757537AbdCUPzs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Mar 2017 11:55:48 -0400
In-Reply-To: <20170315163916.gins7lzzqhwkvfrc@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Harald,

On 03/15/2017 05:39 PM, Harald Welte wrote:
> Hi Jonas,
>
> are you working on the review feedback that was provided back in early
> February?  I think there were some comments like
> * remove unrelated cosmetic change in comment
> * change from FLAGS to a dedicated MODE netlink attribute
> * add libgtpnl code and some usage information or even sample scripts
>
> I would definitely like to see this move forward, particularly in order
> to test the GGSN-side code.

Sorry for the delay in this.

I've sent, just now, revised patches to the kernel module.

I was going to send some libgtpnl patches but I noticed, when gathering 
these up, that you have already made most of the necessary changes on a 
new branch.  What you've got there is almost identical to what I've got.

Since you used the terminology "role" instead of "mode" in your libgtpnl 
branch, I made the corresponding change in the kernel module, too, so it 
now calls this role instead of mode.

Regards,
Jonas




>
> Regards,
> 	Harald
