From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] bridge: Unbreak netconsole
Date: Sat, 8 Feb 2014 18:44:49 -0800
Message-ID: <CAHA+R7OavspZhWH=MEE2dwnj+iyekTttRyQiYHbVNgB_52t7WQ@mail.gmail.com>
References: <52F67A4B.9000504@acm.org>
	<20140208180511.533e1d98@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Bart Van Assche <bvanassche@acm.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Neil Horman <nhorman@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:36405 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403AbaBICov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Feb 2014 21:44:51 -0500
Received: by mail-la0-f51.google.com with SMTP id c6so3842706lan.10
        for <netdev@vger.kernel.org>; Sat, 08 Feb 2014 18:44:50 -0800 (PST)
In-Reply-To: <20140208180511.533e1d98@samsung-9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 8, 2014 at 5:05 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Sat, 08 Feb 2014 19:41:15 +0100
> Bart Van Assche <bvanassche@acm.org> wrote:
>
>> Sending netconsole messages over a bridge network interface doesn't
>> work anymore since kernel v3.12. Bisecting this led to the patch
>> "bridge: cleanup netpoll code". Hence revert that patch (commit
>> 93d8bf9fb8f39d6d3e461db60f883d9f81006159).
>>
>> Signed-off-by: Bart Van Assche <bvanassche@acm.org>
>> Cc: Stephen Hemminger <stephen@networkplumber.org>
>> Cc: Jiri Pirko <jiri@resnulli.us>
>> Cc: Neil Horman <nhorman@tuxdriver.com>
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: <stable@vger.kernel.org> # 3.12
>> Reference: https://bugzilla.kernel.org/show_bug.cgi?id=70071
>
> Cong already send an alternative fix for this.

And it is already in -net:

commit dbe173079ab58a444e12dbebe96f5aec1e0bed1a
Author: Cong Wang <cwang@twopensource.com>
Date:   Thu Feb 6 15:00:52 2014 -0800

    bridge: fix netconsole setup over bridge
