From: Rick Jones <rick.jones2@hp.com>
Subject: Re: low vxlan throughput with tso enabled
Date: Tue, 03 Feb 2015 08:36:15 -0800
Message-ID: <54D0F8FF.1090204@hp.com>
References: <bde634e5-3c57-4e80-9309-670cbd51c1b9@DE-WIE-EXCH3A.green.sophos>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: svens@stackframe.org, Vittorio Curcio <Vittorio.Curcio@Sophos.com>
To: Reiner Herrmann <reiner.herrmann@sophos.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3426.houston.hp.com ([15.201.208.54]:34029 "EHLO
	g4t3426.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965742AbbBCQgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 11:36:18 -0500
In-Reply-To: <bde634e5-3c57-4e80-9309-670cbd51c1b9@DE-WIE-EXCH3A.green.sophos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/2015 07:50 AM, Reiner Herrmann wrote:
> I have a vxlan tunnel established between two network interfaces, which
> both have a MTU of 1500. The vxlan interfaces have the same MTU.
> With TSO enabled, I observe low throughput with TCP connections (<100
> kB/s).
> Disabling TSO works around this issue and throughput is as expected.
> Can someone please explain how TSO is influencing the tunnel to cause
> such a difference?

I've been under the impression that one generally wants the MTU of a 
tunnel interface to be no more than the MTU of the physical interface 
over which it runs, less the size of the encapsulation headers used by 
the tunnel.  What happens when you make the MTU of the tunnel interface 
1400 bytes instead of 1500?

rick jones
