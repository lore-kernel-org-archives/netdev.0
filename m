From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Fw: [Bug 93901] New: TCP Fast Open uses
Date: Thu, 26 Feb 2015 09:58:56 -0800
Message-ID: <54EF5EE0.7040404@hp.com>
References: <20150226080729.4c567be9@urahara> <1424967203.5565.164.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	rueth@comsys.rwth-aachen.de
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3426.houston.hp.com ([15.201.208.54]:39463 "EHLO
	g4t3426.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932338AbbBZR67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 12:58:59 -0500
In-Reply-To: <1424967203.5565.164.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/26/2015 08:13 AM, Eric Dumazet wrote:
> This is work in progress at Google, of course.
>
> Classic chicken and egg problem ;)

Does it need to be any more complicated than a sysctl which enables 
accepting an alternate (the experimental) option value in addition to 
the assigned, to be enabled (perhaps by default for a release or three) 
for the server side, and then just switching the active connection 
establishment side to the assigned number?

If the server is "old" and using the experimental version, the only 
thing that will happen is the clients using the standardized version 
will end-up falling back on the classic three-way handshake.  That 
doesn't seem so bad.  Particularly since that option value was 
"experimental" after all and presumably then not really meant for 
"production" purposes :)

rick jones
