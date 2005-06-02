From: "Anders K. Pedersen" <akp@cohaesio.com>
Subject: Re: Problems with Broadcom and Intel PRO/1000 cards
Date: Thu, 02 Jun 2005 13:34:09 +0200
Message-ID: <d7mqpp$pnn$1@harrier.cohaesio.com>
References: <200506021238.25615.jtbbesaa@aintel.bi.ehu.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alfredo Beaumont Sainz wrote:
> I've a dual opteron machine with an integrated dual Broadcom 5704 10/100/1000 
> (tg3 driver) and an Intel PRO/1000 MT (e1000 driver). It seems that I cannot 
> make them work a Gbps. I've a crossover cable connecting a interface of the 
> Broadcom (eth1) with the Intel (eth2), but they connect at 100Mbps:
> 
> # /sbin/mii-tool -v

mii-tool does not (yet) support more than 100 Mbit/s, so it will report
a 1000 Mbit/s connection as only running 100 Mbit/s. Use ethtool for now.

Regards,
Anders K. Pedersen
