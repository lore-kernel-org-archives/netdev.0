From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: significant napi_gro_frags() slowdown
Date: Thu, 27 Mar 2014 18:05:48 +0100
Message-ID: <53345A6C.5080008@redhat.com>
References: <5334542F.1050702@redhat.com> <1395938874.12610.306.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3956 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752124AbaC0RF4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2014 13:05:56 -0400
In-Reply-To: <1395938874.12610.306.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dne 27.3.2014 17:47, Eric Dumazet napsal:
> On Thu, 2014-03-27 at 17:39 +0100, Michal Schmidt wrote:
>> I received a report about a performance regression on a simple workload
>> of receiving a single TCP stream using a be2net NIC. Previously the
>> reporter was able to reach more than 9 Gb/s, but now he sees less than 7
>> Gb/s.
>
> Yeah, we are aware of this, and we had some discussions, but not yet got
> a fix.
>
> Are you running a 64 or 32bit kernel BTW ?

Both my reporter and I are running 64bit kernels.

Thanks,
Michal
