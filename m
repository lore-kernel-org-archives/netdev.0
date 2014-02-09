From: Bart Van Assche <bvanassche@acm.org>
Subject: Re: [PATCH] bridge: Unbreak netconsole
Date: Sun, 09 Feb 2014 09:46:11 +0100
Message-ID: <52F74053.8030007@acm.org>
References: <52F67A4B.9000504@acm.org>	<20140208180511.533e1d98@samsung-9> <CAHA+R7OavspZhWH=MEE2dwnj+iyekTttRyQiYHbVNgB_52t7WQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Neil Horman <nhorman@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp03.stone-is.org ([87.238.162.65]:38928 "EHLO
	smtpgw.stone-is.be" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751403AbaBIIqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Feb 2014 03:46:17 -0500
In-Reply-To: <CAHA+R7OavspZhWH=MEE2dwnj+iyekTttRyQiYHbVNgB_52t7WQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/09/14 03:44, Cong Wang wrote:
> On Sat, Feb 8, 2014 at 5:05 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
>> On Sat, 08 Feb 2014 19:41:15 +0100
>> Bart Van Assche <bvanassche@acm.org> wrote:
>>
>>> Sending netconsole messages over a bridge network interface doesn't
>>> work anymore since kernel v3.12. Bisecting this led to the patch
>>> "bridge: cleanup netpoll code". Hence revert that patch (commit
>>> 93d8bf9fb8f39d6d3e461db60f883d9f81006159).
>>>
>>> Signed-off-by: Bart Van Assche <bvanassche@acm.org>
>>> Cc: Stephen Hemminger <stephen@networkplumber.org>
>>> Cc: Jiri Pirko <jiri@resnulli.us>
>>> Cc: Neil Horman <nhorman@tuxdriver.com>
>>> Cc: David S. Miller <davem@davemloft.net>
>>> Cc: <stable@vger.kernel.org> # 3.12
>>> Reference: https://bugzilla.kernel.org/show_bug.cgi?id=70071
>>
>> Cong already send an alternative fix for this.
> 
> And it is already in -net:
> 
> commit dbe173079ab58a444e12dbebe96f5aec1e0bed1a
> Author: Cong Wang <cwang@twopensource.com>
> Date:   Thu Feb 6 15:00:52 2014 -0800
> 
>     bridge: fix netconsole setup over bridge

Thanks Cong and Stephen for working on a fix, and sorry that I had not
noticed that a fix was already available before I sent the patch at the
start of this e-mail thread.

Bart.
