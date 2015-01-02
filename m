From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next] openvswitch: Do not set skb ignore_df
Date: Fri, 2 Jan 2015 15:03:04 -0500
Message-ID: <CAEP_g=-dmtKbC+GkOsr1Z+gUB6Q0noFP_O5PhXmhs_w3j0BV0Q@mail.gmail.com>
References: <1420223248-1681-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog113.obsmtp.com ([74.125.149.209]:35240 "HELO
	na3sys009aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752207AbbABUDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 15:03:25 -0500
Received: by mail-qa0-f48.google.com with SMTP id k15so10492642qaq.7
        for <netdev@vger.kernel.org>; Fri, 02 Jan 2015 12:03:24 -0800 (PST)
In-Reply-To: <1420223248-1681-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 2, 2015 at 1:27 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> Tunnel transmit code clear this bit, so setting ignore_df has
> no effect.
>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Is it actually right for the bit to be cleared though? As discussed in
the previous thread on tunnel MTU handling, I think that fragmentation
should be done as a very last resort.
