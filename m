From: Martin Devera <devik@cdi.cz>
Subject: Re: Possible regression in HTB
Date: Thu, 09 Oct 2008 13:22:30 +0200
Message-ID: <48EDE976.5040803@cdi.cz>
References: <48EB5A92.6010704@trash.net> <20081007220022.GA2664@ami.dom.local> <20081008002153.GL12021@verge.net.au> <48EBFF5E.1090902@trash.net> <48EC0190.7040804@trash.net> <48EC6286.1030202@cdi.cz> <20081008085325.GF4174@ff.dom.local> <48EC8FDD.5030507@cdi.cz> <20081009010957.GB6342@verge.net.au> <48EDA339.3040706@cdi.cz> <20081009111100.GA28667@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.wifcom.cz ([89.185.251.8]:48272 "EHLO wifcom.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756543AbYJILWg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2008 07:22:36 -0400
In-Reply-To: <20081009111100.GA28667@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> r2q affects computation for all classes
> 
> Sorry, I wasn't aware of that parameter.
> I ran a test now. With the default quantum (6250) for the 500Mbit/s
> class I got:
> 
> 10194: 383384949bits/s 383Mbits/s
> 10197: 285879669bits/s 285Mbits/s
> 10196: 287648424bits/s 287Mbits/s
> -----------------------------------
> total: 956913042bits/s 956Mbits/s
> 
> And when a quantum of 50000 for the 500Mbit/s class I got:
> 
> 10194: 396345613bits/s 396Mbits/s
> 10197: 279511994bits/s 279Mbits/s
> 10196: 281062498bits/s 281Mbits/s
> -----------------------------------
> total: 956920106bits/s 956Mbits/s

thanks! it seems there is no strong dependence. I'm out of simple
explanations and I'd have to simulate it myself.
Unfortunately I can't say when I can do it as I'm in complicated
part of life now....
So that let's live with that 90% of max rate limitation for now.
