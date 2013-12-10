From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Fwd: UDP/IPv6 performance issue
Date: Tue, 10 Dec 2013 09:05:15 -0800
Message-ID: <52A749CB.1010909@hp.com>
References: <CAGA2gK6rf8E7cCO=RwbdFAt2ucfxUbCjqhVoga9cnHrEKxcp9g@mail.gmail.com> <CAGA2gK5gfdaKeQWzT4Dd45AhavD4pYaCVyayf7Hd+q5pPUjfKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: ajay seshadri <seshajay@gmail.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:33356 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755120Ab3LJRFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 12:05:16 -0500
In-Reply-To: <CAGA2gK5gfdaKeQWzT4Dd45AhavD4pYaCVyayf7Hd+q5pPUjfKQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If you want to compare the "fundamental" path length difference between 
IPv4 and IPv6, without any concerns about stateless offloads like CKO or 
GRO et al, you could use something like a single-byte netperf TCP_RR test.

netperf -c -C -H <remote> -t TCP_RR

and then compare service demands between the two cases.   You can add a 
"-i 30,3" to have netperf run several iterations to get a better idea of 
how close it is to the "real" mean result.

happy benchmarking,

rick jones
