From: Simon Oosthoek <wmc_simon@fastmail.fm>
Subject: Re: [ANNOUNCE] FLAME: external kernel module for L2.5 meshing
Date: Thu, 25 May 2006 11:36:46 +0200
Message-ID: <44757AAE.1000305@fastmail.fm>
References: <44731733.7000204@ti-wmc.nl> <20060524205035.GA4149@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herman.elfrink@ti-wmc.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpq1.tilbu1.nb.home.nl ([213.51.146.200]:49076 "EHLO
	smtpq1.tilbu1.nb.home.nl") by vger.kernel.org with ESMTP
	id S965097AbWEYJgc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 05:36:32 -0400
To: Pavel Machek <pavel@ucw.cz>
In-Reply-To: <20060524205035.GA4149@ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pavel

(I've removed linux-kernel from CC, this is only network related and 
added Herman to the CC, since he's not subscribed)

Pavel Machek wrote:
> Hi!
> 
>> FLAME stands for "Forwarding Layer for Meshing"
>>
>> FLAME provides an intermediate layer between the network 
>> layer (e.g. IPv4/IPv6) and the link (MAC) layer, 
>> providing L2.5 meshing. Both network layer and MAC layer 
> 
> What is wrong with meshing on L3?
> 

Well, I think mostly that L3 meshing is not quite ready to be usable, 
especially if you want to mix IPv4 and IPv6 stacks in the same network 
(dual-stack).

L3 meshing is better for mixing multiple different link layers, but you 
still need to solve address assignment problems and routing, which can 
become quite complicated at L3. In our case, we use dual-stack in a 
hopping network behind a mobile router (which delegates a mobile network 
prefix, NEMO: rfc 3963). In a short-range hopping network (e.g. a PAN) 
using 802.xxx type network interfaces, FLAME is much faster and easier 
to implement than trying to solve it at L3 (twice; dual-stack).

We are of course also interested in good L3 solutions, but so far, we 
haven't come across a good one ;-)

> (It is called flame so lets at least have nice flamewar :-)
> 							Pavel

flamewars are highly overrated IMHO ;-)

Cheers

Simon
