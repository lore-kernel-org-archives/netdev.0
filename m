From: Koon Wah Yick <kyick@alcatel-lucent.com>
Subject: Re: Enable netem in my Linux box
Date: Thu, 10 May 2007 14:36:24 -0400
Message-ID: <46436628.6090405@lucent.com>
References: <4641E945.3070902@lucent.com>	<20070510084232.147e1d8f@freepuppy>	<464343CA.6090500@lucent.com>	<20070510095738.563a23bf@localhost>	<46435DC8.6000807@lucent.com> <20070510112302.770237f1@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Koon Wah Yick <kyick@alcatel-lucent.com>, netdev@vger.kernel.org,
	"Yick, Koon Wah (Koon)" <kyick@homail.ho.lucent.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hoemail2.lucent.com ([192.11.226.163]:44537 "EHLO
	hoemail2.lucent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754744AbXEJSga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 14:36:30 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen:

Thank you.  I am happy that when I issue the tc command to drop packets, I do
see the effect.  Is there a command I can use to show all packet count?  packet
send, packet received and packet drop etc...  I don't seems to be able to see
them by command "ifconfig".

Koon-Wah.

On 5/10/2007 2:23 PM, Stephen Hemminger wrote:
> On Thu, 10 May 2007 14:00:40 -0400
> Koon Wah Yick <kyick@alcatel-lucent.com> wrote:
> 
> 
>>Stephen:
>>
>>Thank you, I got it.  I try the same command again with "add" and "change" they
>>all work.(no error)  But when I start my Network Emulator, how can I stop it.
>>Do I have to delete any file I create when doing "add"?  If yes, where is it?
> 
> 
> You probably just want to do: 
> tc qdisc del dev eth0 root
> 
> That restores the default qdisc (prio-fast)
> 


