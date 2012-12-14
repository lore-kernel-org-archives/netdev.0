From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [Netperf PATCH] output remote_send_size in TCP_MAERTS result
Date: Fri, 14 Dec 2012 13:27:56 -0800
Message-ID: <50CB99DC.8030304@hp.com>
References: <1355482148-31407-1-git-send-email-akong@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Amos Kong <akong@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:2151 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932418Ab2LNV15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 16:27:57 -0500
In-Reply-To: <1355482148-31407-1-git-send-email-akong@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/14/2012 02:49 AM, Amos Kong wrote:
> When I executed TCP_MAERTS by following command line:
>    netperf-2.6.0 -H 192.168.58.23 -l 10 -C -t TCP_MAERTS -- -m 512,1024
> The outputed send size is '512'.
>
> When I executed TCP_MAERTS by following command line:
>    netperf-2.6.0 -H 192.168.58.23 -l 10 -t TCP_MAERTS -- -m 512,1024
> The outputed send size is '1024'.
>
> In TCP_MAERTS test, we should output the remote send size '1024',
> this patch fixed this issue.

Hi Amos -

While I suspect at least a few folks on the netdev list are interested 
in "things netperf," netperf is not maintained via the netdev list. 
There are two lists hosted on netperf.org which pertain to "things 
netperf."  The first is netperf-talk which is geared towards users.  The 
second netperf-dev which is geared towards those developing netperf.

No need to re-post there this time (though feel free to for the 
archives), I've gone ahead and applied the fix to the netperf top-of-trunk.

happy benchmarking,

rick jones
