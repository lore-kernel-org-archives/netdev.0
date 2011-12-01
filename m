From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH v3 net-next 2/2] netem: add cell concept to simulate  special MAC behavior
Date: Thu, 01 Dec 2011 09:25:20 +0100
Message-ID: <cfd2e2c26063da002d8afe76991ff0c1@localhost>
References: <1322691627-20551-1-git-send-email-hagen@jauu.net>
 <1322691627-20551-2-git-send-email-hagen@jauu.net>
 <1322710225.2577.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:34126 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751676Ab1LAIZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 03:25:24 -0500
In-Reply-To: <1322710225.2577.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 01 Dec 2011 04:30:25 +0100, Eric Dumazet wrote:



> Thats a multiply instead of a divide. On many cpus thats a lot faster.

>

> Think about a super packet (TSO) of 65000 bytes and cell_size=64



I've never imagined that I am going to say the following: you are wrong,

Eric! (ok, maybe you are right ;-)



TSO and Netem is a no-go. With netem you are strongly advised to disable

offloading. I mean TSO will result in _one_ delay of several minutes,

followed by a burst of packets. Instead of packets spaced by several

seconds (with the rate of 1000byte/s) - which is what you wan't.



To sum up: skb->len is _never_ larger as the MTU for (normal, correct)

network emulation setups with netem. This was the assumption why I

preferred the iterative solution over the div/mod solution.



Did I miss something?



Hagen
