From: Rick Jones <rick.jones2@hp.com>
Subject: Re: UDP Out 0f Sequence
Date: Wed, 20 Sep 2006 09:47:02 -0700
Message-ID: <45117086.6080406@hp.com>
References: <F444CAE5E62A714C9F45AA292785BED30EB97591@esng11p33001.sg.csfb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:54158 "EHLO palrel11.hp.com")
	by vger.kernel.org with ESMTP id S1751880AbWITQrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2006 12:47:03 -0400
To: "Majumder, Rajib" <rajib.majumder@credit-suisse.com>
In-Reply-To: <F444CAE5E62A714C9F45AA292785BED30EB97591@esng11p33001.sg.csfb.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Majumder, Rajib wrote:
> Hi,
> 
> If I write UDP datagrams 1,2 and 3 to network and if the receiver
> receives in order 2,1, and 3, where can the sequence get changed? Is it
> at the source stack, network transit or destination stack?

Yes. :)

Although network transit is by far the most likely case.  Destination 
stack is a distant second and source stack an even more distant third. 
Generally stack writers try to avoid having places in their stacks where 
things can reorder, but it isn't completely unknown.

rick jones
