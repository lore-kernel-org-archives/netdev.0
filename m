From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] xt_TCPMSS: SYN packets are allowed to contain data
Date: Thu, 21 Jan 2010 13:58:19 +0100 (CET)
Message-ID: <alpine.LSU.2.01.1001211356180.30772@obet.zrqbmnf.qr>
References: <4B54CDE5.3070100@simon.arlott.org.uk> <4B5578A5.50705@gmail.com>    <dad314e12c5750b1b5d70c3ea3c6f6134b8fa0f3@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>    <4B55D372.4020807@gmail.com>    <710ab0ca79305c82013982d43250b0a1fd45824d@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>
    <4B5773C2.2010000@simon.arlott.org.uk>    <alpine.LSU.2.01.1001202238400.18680@obet.zrqbmnf.qr>    <alpine.LSU.2.01.1001202240350.18680@obet.zrqbmnf.qr>    <4B578E59.8090203@trash.net>
 <0b01c450344abffd72a5b1b037ee6584e6db6b82@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	William Allen Simpson <william.allen.simpson@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <0b01c450344abffd72a5b1b037ee6584e6db6b82@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thursday 2010-01-21 13:47, Simon Arlott wrote:
>
>The TCPMSS target can be applied to more than just one direction
>of traffic. I'm modifying incoming traffic too, so adding the MSS
>option and setting it to over 536 is wrong (although the first ICMP
>error will fix it).
>
>Existing users use this target precisely because their hosts are
>sending an unwanted MSS value, so it will never need to be added.

Ah, so they should be using TCPOPTSTRIP ;-)

