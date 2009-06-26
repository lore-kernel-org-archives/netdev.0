From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [Bugme-new] [Bug 13627] New: Tunnel device ignores TCP/UDP traffic
Date: Fri, 26 Jun 2009 22:51:44 +0200
Message-ID: <4A4534E0.5070903@hartkopp.net>
References: <bug-13627-10286@http.bugzilla.kernel.org/> <20090626124444.c24d9b38.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, pm@debian.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:56855 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754278AbZFZUwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 16:52:03 -0400
In-Reply-To: <20090626124444.c24d9b38.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Fri, 26 Jun 2009 14:45:11 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=13627
>>
>>            Summary: Tunnel device ignores TCP/UDP traffic
>>            Product: Networking
>>            Version: 2.5
>>     Kernel Version: 2.6.31-rc1
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: IPV4
>>         AssignedTo: shemminger@linux-foundation.org
>>         ReportedBy: pm@debian.org
>>         Regression: Yes
>>
> 
> It's a post-2.6.30 regression which Paul has bisected down to
> 
>   commit d55d87fdff8252d0e2f7c28c2d443aee17e9d70f
>   Author:     Herbert Xu <herbert@gondor.apana.org.au>
>   AuthorDate: Mon Jun 22 02:25:25 2009 +0000
>   Commit:     David S. Miller <davem@davemloft.net>
>   CommitDate: Tue Jun 23 16:36:25 2009 -0700
> 
>       net: Move rx skb_orphan call to where needed
> 
> (thanks for doing the bisection!)
> 
>> Using OpenVPN on 2.6.29.4 and 2.6.30 works but 2.6.31-rc1 doesn't.
>>
>> I can ping (ICMP) the remote end, and see the packets going back and forth
>> using tcpdump, but they don't appear to be reaching the upper layers.
>>

Sorry that i did not test tunnels also.

I just checked whether the patch from Herbert fixed the regression for PF_CAN
sockets (which it does) - and of course i used 'normal' IP networking.

I hope the tunnel can be fixed without reverting the whole patch ...

Regards,
Oliver

