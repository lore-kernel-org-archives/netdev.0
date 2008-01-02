From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [patch 0/9][NETNS][IPV6] make sysctl per namespace
Date: Wed, 02 Jan 2008 15:05:04 +0100
Message-ID: <477B9A10.4020803@fr.ibm.com>
References: <20080102122548.629622062@localhost.localdomain> <20080102145434.8bdba06d.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:46364 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752634AbYABONm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 09:13:42 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m02EDSr6039696
	for <netdev@vger.kernel.org>; Wed, 2 Jan 2008 14:13:28 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m02EDSmj5107744
	for <netdev@vger.kernel.org>; Wed, 2 Jan 2008 14:13:28 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m02EDB42020722
	for <netdev@vger.kernel.org>; Wed, 2 Jan 2008 14:13:12 GMT
In-Reply-To: <20080102145434.8bdba06d.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> On Wed, 02 Jan 2008 13:25:48 +0100
> Daniel Lezcano <dlezcano@fr.ibm.com> wrote:
> 
>> The following patchset makes the ipv6 sysctl to handle multiple
>> network namespaces. Each instance of a network namespace as its own
>> set of sysctl values, that means the behavior of the ipv6 stack can be
>> different depending on the sysctl values setup in the different
>> network namespaces.
> 
> Hi Daniel
> 
> Did you tested your patches with CONFIG_SYSCTL=n ?
> 
> For example, I had to apply this patch on current git.
> 
> Thank you
> 
> [PATCH] IPV4 : Should build with CONFIG_SYSCTL=n
> 
> Previous NETNS patches broke CONFIG_SYSCTL=n case
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Thanks Eric for fixing that.

I compiled with CONFIG_SYSCTL=n and booted.
I try to always do allmodconfig, allyesconfig, allnoconfig with a 
cross-compiler for different arch, i386, x86_64, s390, ppc, ia64, sh, 
sparc, arm and alpha, before sending to netdev@.

  -- Daniel
