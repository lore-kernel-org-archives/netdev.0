From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next] openvswitch: Do not set skb ignore_df
Date: Fri, 2 Jan 2015 14:44:38 -0800
Message-ID: <CALnjE+qr4vvnxNX=bkyQ0H=8WW2Qgsbqqzxm16hop3PRx6-O=Q@mail.gmail.com>
References: <1420223248-1681-1-git-send-email-pshelar@nicira.com>
	<CAEP_g=-dmtKbC+GkOsr1Z+gUB6Q0noFP_O5PhXmhs_w3j0BV0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog102.obsmtp.com ([74.125.149.69]:59342 "HELO
	na3sys009aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752197AbbABWoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 17:44:39 -0500
Received: by mail-ig0-f175.google.com with SMTP id h15so203572igd.14
        for <netdev@vger.kernel.org>; Fri, 02 Jan 2015 14:44:38 -0800 (PST)
In-Reply-To: <CAEP_g=-dmtKbC+GkOsr1Z+gUB6Q0noFP_O5PhXmhs_w3j0BV0Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 2, 2015 at 12:03 PM, Jesse Gross <jesse@nicira.com> wrote:
> On Fri, Jan 2, 2015 at 1:27 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
>> Tunnel transmit code clear this bit, so setting ignore_df has
>> no effect.
>>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>
> Is it actually right for the bit to be cleared though? As discussed in
> the previous thread on tunnel MTU handling, I think that fragmentation
> should be done as a very last resort.

ok, I missed the discussion, I will send another patch.
