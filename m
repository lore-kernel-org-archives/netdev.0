From: Koon Wah Yick <kyick@alcatel-lucent.com>
Subject: Re: Enable netem in my Linux box
Date: Thu, 10 May 2007 14:00:40 -0400
Message-ID: <46435DC8.6000807@lucent.com>
References: <4641E945.3070902@lucent.com>	<20070510084232.147e1d8f@freepuppy>	<464343CA.6090500@lucent.com> <20070510095738.563a23bf@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Koon Wah Yick <kyick@alcatel-lucent.com>, netdev@vger.kernel.org,
	"Yick, Koon Wah (Koon)" <kyick@homail.ho.lucent.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hoemail2.lucent.com ([192.11.226.163]:56815 "EHLO
	hoemail2.lucent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755AbXEJSBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 14:01:16 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen:

Thank you, I got it.  I try the same command again with "add" and "change" they
all work.(no error)  But when I start my Network Emulator, how can I stop it.
Do I have to delete any file I create when doing "add"?  If yes, where is it?

Koon-Wah.

On 5/10/2007 12:57 PM, Stephen Hemminger wrote:
> On Thu, 10 May 2007 12:09:46 -0400
> Koon Wah Yick <kyick@alcatel-lucent.com> wrote:
> 
> 
>>Stephen:
>>
>>Thank you for your response, I type in modinfo sch_netem
>>
>>Here is what I got:
>>
>>filename: /lib/modules/2.6.11-1.1369_FC4/kernel/net/sched/sch_netem.ko
>>license: GPL
>>vermagic: 2.6.11-1.l369_FC 686 REGPARM 4KSTACKS gcc-4.0
>>depends:
>>srcversion: BD4563861423428FF0D5918
>>
>>when I try the following "tc" command with netem
>>
>>
>>>tc qdisc change dev eth0 root netem loss 0.1%
>>
>>I got the error message
>>RTNETLINK answers: No such file or directory.
>>
> 
> 
> You want to use 'add' not 'change'.
> The examples on the linux-net page are sequential, so the first one uses 'add'.
> Later examples, then use change to alter parameters


