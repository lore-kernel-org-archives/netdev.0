From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: ProxyARP and IPSec
Date: Tue, 5 Sep 2006 02:27:22 +0400
Message-ID: <20060904222722.GA24078@ms2.inr.ac.ru>
References: <20060823.151424.78711856.davem@davemloft.net> <20060823231812.GA32394@ms2.inr.ac.ru> <44ECFCF1.10500@zytor.com> <44ECFD5F.6060901@zytor.com> <1156386043.7302.773.camel@tahini.andynet.net> <44ED2797.4070304@zytor.com> <20060824125046.GA25439@ms2.inr.ac.ru> <44EFCB0F.5080506@zytor.com> <17657.42254.455342.157858@localhost.localdomain> <44F9BFC2.4050001@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Stephen J. Bevan" <stephen@dino.dnsalias.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:50306 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S932143AbWIDW1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2006 18:27:48 -0400
To: "H. Peter Anvin" <hpa@zytor.com>
Content-Disposition: inline
In-Reply-To: <44F9BFC2.4050001@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> <sarcasm>
> 
> What I great idea.  Now I just have to get every host I want to 
> interoperate with to support a nonstandard configuration.  The scary 
> part is that if I motivate it with "Linux is too stupid to handle 
> standard tunnel-mode IPsec" I might actually get away with it.

sarcasm mode is not accepted. Linux does exactly "standard tunnel-mode IPsec".
It does not give you device to make you totally happy.

Probably, you are not aware that "standard IPsec tunnel device",
if it is created:

1. Probably, will not accept fragmented frames, because IPsec cannot
   handle them
2. Probably, will have undefined MTU (65536), because of 1
3. Probably, will screw up TCP because of 2
   etc.

Actually, this is the reason why it is not implemented.
It is dirty business. :-) And the person, who implements this,
has to be really... unscrupulous. :-)

Alexey
