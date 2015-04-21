From: "Vitaly E. Lavrov" <lve@guap.ru>
Subject: Re: [RFC PATCH] tc filter not show last u32 filter
Date: Tue, 21 Apr 2015 23:07:24 +0300
Message-ID: <5536ADFC.8070601@guap.ru>
References: <55368E7F.4030005@guap.ru> <55369446.10806@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.guap.ru ([91.151.188.3]:19693 "EHLO ns1.guap.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755985AbbDUUH2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Apr 2015 16:07:28 -0400
In-Reply-To: <55369446.10806@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21.04.2015 21:17, Sergei Shtylyov wrote:
> Hello.
>
> On 04/21/2015 08:53 PM, Vitaly E. Lavrov wrote:
>
>> "tc filter show" does not show last U32 filter on 32-bit systems (tested on x86).
>
>> Additional condition: filter does not have action and CONFIG_NET_CLS_ACT=y
>
>> Example: tc filter add dev eth0 parent 1:0 protocol ip prio 100 u32 match ip
>> dst 10.200.2.2 flowid 1:20
>
>
>     You need to send patches against the latest kernel. Look for DaveM's 'net.git' repo on git.kernel.org.
 >    Please run your patches thru scripts/chackpatch.pl; space is needed after *if*.
Thanks for the reminder about the rules.
Sorry that have not checked all branches of the kernel.

A similar patch is already exists in the git.kernel.org/linux-stable.git/master (commit b057df24a7536cce6c372efe9d0e3d1558afedf4)
and linux-4.0.y.

The patch can be applied to branches of the kernel 3.14, 3.18 and 3.19.  Why is this not done at once?
