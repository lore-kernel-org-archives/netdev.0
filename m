From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter: nf_conntrack_ipv4 does not show nf_nat as a user
Date: Wed, 07 Nov 2007 00:51:31 +0100
Message-ID: <4730FE03.5010701@trash.net>
References: <472F78C9.9060900@redhat.com> <472FB162.7050507@trash.net> <4730C094.4070406@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45126 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753512AbXKFXvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 18:51:43 -0500
In-Reply-To: <4730C094.4070406@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chuck Ebbert wrote:
> On 11/05/2007 07:12 PM, Patrick McHardy wrote:
>> Chuck Ebbert wrote:
>>> https://bugzilla.redhat.com/show_bug.cgi?id=333481#c3
>>>
>>> This is netfilter kernel problem. There is a usage count for the
>>> conntrack_ipv4
>>> module from the nf_nat module, which is not reported by lsmod.
>>>   
>> This is "fixed" in the current kernel.
> 
> By this hack?
> 
> [NETFILTER]: Fix/improve deadlock condition on module removal netfilter

Thats not really a hack, the patch is fully correct, the bug was in
modutils.

The patch I'm talking about is 591e6206:

[NETFILTER]: nf_nat: add symbolic dependency on IPv4 conntrack
