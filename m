From: Rick Jones <rick.jones2@hp.com>
Subject: Re: VxLAN system wedge in 4.0.0-rc5+ from davem net-next?
Date: Mon, 06 Apr 2015 13:00:53 -0700
Message-ID: <5522E5F5.7050605@hp.com>
References: <551F2C20.1060908@hp.com> <20150406190743.GA3969@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hp.com ([15.217.136.92]:53375 "EHLO
	g2t1383g.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753717AbbDFUAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 16:00:55 -0400
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com [15.240.92.67])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by g2t1383g.austin.hp.com (Postfix) with ESMTPS id 11CF634E2
	for <netdev@vger.kernel.org>; Mon,  6 Apr 2015 20:00:55 +0000 (UTC)
In-Reply-To: <20150406190743.GA3969@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/06/2015 12:07 PM, Marcelo Ricardo Leitner wrote:
> Hi,
>
> On Fri, Apr 03, 2015 at 05:11:12PM -0700, Rick Jones wrote:
>> Hi -
>>
>> I've been messing about with VxLAN with a pair of two socket systems with
>> ixgbe-driven NICs (HP 560FLRs for the curious) and have noticed that with a
>> kernel from a davem net-next tree I refreshed a couple days ago I can create
>> the vlxan link, and ifconfig it, but once I start trying to push packets
>> through it the system appears to hang and I have to reset it.
>>
>> I went back to checkout v3.19 and tried that kernel and all was happiness
>> and joy.  So, I started down the bisect path, but after the first iteration
>> I ran into:
>
> That means you could send/receive some packets on it before the hang, right?

On v3.19 I could send and receive lots of packets without a hang.  I 
could even run netperf through the vxlan tunnel :)

Now that I've addressed my build issue I'm in the midst of a bisect, but 
if someone has faster git-fu I'll not be disappointed if they are able 
to bisect before me.

rick
