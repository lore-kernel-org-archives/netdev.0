From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] xt_TCPMSS: SYN packets are allowed to contain data
Date: Wed, 20 Jan 2010 22:41:59 +0100 (CET)
Message-ID: <alpine.LSU.2.01.1001202240350.18680@obet.zrqbmnf.qr>
References: <4B54CDE5.3070100@simon.arlott.org.uk> <4B5578A5.50705@gmail.com>    <dad314e12c5750b1b5d70c3ea3c6f6134b8fa0f3@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>    <4B55D372.4020807@gmail.com> <710ab0ca79305c82013982d43250b0a1fd45824d@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>
 <4B5773C2.2010000@simon.arlott.org.uk> <alpine.LSU.2.01.1001202238400.18680@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	William Allen Simpson <william.allen.simpson@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1001202238400.18680@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 2010-01-20 22:39, Jan Engelhardt wrote:

>On Wednesday 2010-01-20 22:21, Simon Arlott wrote:
>
>>The TCPMSS target is dropping SYN packets where:
>>  1) There is data, or
>>  2) The data offset makes the TCP header larger than
>>  the packet.
>>
>>Both of these result in an error level printk.
>>
>>This change fixes the drop of SYN packets with data
>>(because the MSS option can safely be modified) and
>>passes packets with no MSS option instead of adding
>>one (which is not valid).
>
>Can you explain why the automatic addition of a MSS option is removed?

That is, of course, for the git log. If I followed the thread right, it 
was that adding the option could exceed the MTU. Well, can't we check 
for the outgoing MTU?
