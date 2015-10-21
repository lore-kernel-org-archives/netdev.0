From: Alan Burlison <Alan.Burlison@oracle.com>
Subject: Re: Fw: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Wed, 21 Oct 2015 14:03:57 +0100
Message-ID: <56278D3D.1010608@oracle.com>
References: <20151019095938.72ea48e6@xeon-e3>	 <1445297584.30896.29.camel@edumazet-glaptop2.roam.corp.google.com>	 <562594E1.8040403@oracle.com>	 <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com>	 <56261092.7080003@oracle.com>	 <1445347173.22974.6.camel@edumazet-glaptop2.roam.corp.google.com>	 <56264596.90104@oracle.com>	 <1445355027.22974.22.camel@edumazet-glaptop2.roam.corp.google.com>	 <5626887D.5050308@oracle.com>	 <063D6719AE5E284EB5DD2968C1650D6D1CBBD206@AcuExch.aculab.com>	 <56276DA2.8010905@oracle.com> <1445426932.22974.43.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:43882 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753329AbbJUNEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 09:04:07 -0400
In-Reply-To: <1445426932.22974.43.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/10/2015 12:28, Eric Dumazet wrote:

> This works for me. Please double check your programs

I have just done so, it works as you say for AF_INET sockets but if you 
switch to AF_UNIX sockets it does the wrong thing in the way I described.

-- 
Alan Burlison
--
