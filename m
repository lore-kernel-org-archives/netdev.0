From: Kir Kolyshkin <kir@openvz.org>
Subject: Re: [Devel] Re: Network virtualization/isolation
Date: Sun, 10 Dec 2006 01:34:14 +0300
Message-ID: <457B39E6.7070404@openvz.org>
References: <453F8800.9070603@fr.ibm.com> <1165239894.3664.61.camel@localhost>	<m1k617u10x.fsf@ebiederm.dsl.xmission.com>	<200612041900.42768.dim@openvz.org>	<m1odqj8uyt.fsf@ebiederm.dsl.xmission.com> <4576AF68.2070604@sw.ru>	<20061206183036.GA16927@MAIL.13thfloor.at>	<m164cm2m9u.fsf@ebiederm.dsl.xmission.com>	<20061209035002.GA11747@MAIL.13thfloor.at>	<20061208221348.b263e3c2.akpm@osdl.org> <20061209063517.GG11747@MAIL.13thfloor.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	hadi@cyberus.ca, Linus Torvalds <torvalds@osdl.org>,
	Linux Containers <containers@lists.osdl.org>,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:33852 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758878AbWLIWgV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Dec 2006 17:36:21 -0500
To: Herbert Poetzl <herbert@13thfloor.at>
In-Reply-To: <20061209063517.GG11747@MAIL.13thfloor.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Poetzl wrote:
> On Fri, Dec 08, 2006 at 10:13:48PM -0800, Andrew Morton wrote:
>   
>>
>> It's actually happening quite gradually and carefully.
>>     
>
> hmm, I must have missed a testing phase for the
> IPC namespace then, not that I think it is broken
> (well, maybe it is, we do not know yet)
>
>   
You have announced at LKML that Linux-VServer now uses the stuff that 
was merged in 2.6.19-rc1, haven't you? I suppose that means you are 
using IPC namespaces from mainstream? Isn't that considered testing? Or 
you don't test Linux-VServer? Please clarify, I'm a bit lost here.

Speaking of OpenVZ, as Kirill Korotaev said before we have backported 
all that to 2.6.18 back in September and are using it since then. And 
yes, we found a bug in IPC namespaces, and fix from Pavel Emelyanov has 
made it to 2.6.19-rc5 (see commit 
c7e12b838989b0e432c7a1cdf1e6c6fd936007f6 to linux-2.6-git).

