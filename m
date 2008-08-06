From: jamal <hadi@cyberus.ca>
Subject: Re: few more fixes for iproute2/m_ipt
Date: Wed, 06 Aug 2008 07:04:46 -0400
Message-ID: <1218020686.4755.42.camel@localhost>
References: <200808060042.53503.denys@visp.net.lb>
	 <1218017085.4755.23.camel@localhost> <200808061321.19560.denys@visp.net.lb>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:33304 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755787AbYHFLEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 07:04:51 -0400
Received: by yw-out-2324.google.com with SMTP id 9so1708863ywe.1
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2008 04:04:50 -0700 (PDT)
In-Reply-To: <200808061321.19560.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-06-08 at 13:21 +0300, Denys Fedoryshchenko wrote:

> #1 is validated 100%, because i was not able to run tc in batch mode for my 
> tasks(2nd or 3rd ipt rule will crash), till i implement those patches. The 
> batch i gave is short version, full version have around 11k lines. But it 
> crashes usually max on 2rd or 3nd ipt.

Ok, thanks - let me take a closer look. 
Actually i dont doubt that when you batch the optind maybe shaky - I am
more worried about other working scenarios that may have depended on it.
I will still say put #2 and #3 in separate patch.

> Well, i can fix what i can sniff&smell in my daily job, and especially if i 
> hit a wall because of some code :-) For me it is difficult to inspect the 
> code, since i am very weak in C, but i will try. 

I understand it could be frustrating sometimes but given
your situation you are doing fantastic work. It is highly appreciated.

cheers,
jamal

