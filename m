From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Fixed PHY regression
Date: Mon, 08 Oct 2007 19:56:34 -0400
Message-ID: <470AC3B2.7090802@garzik.org>
References: <008601c809d7$7f5dc710$04ac10ac@Jocke> <20071008.142057.31775797.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: joakim.tjernlund@transmode.se, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55196 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752204AbXJHX4q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2007 19:56:46 -0400
In-Reply-To: <20071008.142057.31775797.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: "Joakim Tjernlund" <joakim.tjernlund@transmode.se>
> Date: Mon, 8 Oct 2007 20:17:33 +0200
> 
>> David, any chance the second item, Oops while modprobing phy fixed module, in
>> http://marc.info/?l=linux-kernel&m=119178673421891&w=2
>> will make it into 2.6.23? 
>>
>> The fix is now in your tree,
>> http://git.kernel.org/?p=linux/kernel/git/davem/bak-net-2.6.24.git;a=commit;h=bbb4c0c35a4c2aed5e025b668c8dfc99c5b74cff
>>
>> It has been in Andrews tree for a while, then in Garzik and now it is in your tree.
> 
> Jeff, any reason you didn't submit this one for 2.6.23?

Two reasons:
* despite the subject, after discussion it looked like a problem with 
module release, making "build it into your kernel" a valid workaround
* the fix was quite invasive this late in the game

If people still think it should go for 2.6.23, that's cool with me.

	Jeff


