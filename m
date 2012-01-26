From: Glauber Costa <glommer@parallels.com>
Subject: Re: linux-next: Tree for Jan 25 (net/sock.h, jump_label, memcg)
Date: Fri, 27 Jan 2012 01:47:24 +0400
Message-ID: <4F21C9EC.60009@parallels.com>
References: <20120125141938.c1a9460d56948e1c7b26d3f8@canb.auug.org.au> <4F2052DB.4060602@xenotime.net> <CAMuHMdWp1wEHqPXNs+kaMYpomJnfbZPJjRk5GVFCuCL4Q5zK7g@mail.gmail.com> <20120126.134333.31948964659222759.davem@davemloft.net> <4F21B811.90904@parallels.com> <20120127084622.a16b0f43e6fcbd029cb1f923@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <geert@linux-m68k.org>,
	<rdunlap@xenotime.net>, <linux-next@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <gleb@redhat.com>,
	<netdev@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:38090 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752735Ab2AZVsR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 16:48:17 -0500
In-Reply-To: <20120127084622.a16b0f43e6fcbd029cb1f923@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/27/2012 01:46 AM, Stephen Rothwell wrote:
> On Fri, 27 Jan 2012 00:31:13 +0400 Glauber Costa<glommer@parallels.com>  wrote:
>>
>> On the specifics of this bug, I verified this config compiles okay in
>> your tree + my patches at the day I last sent them. I also verified it
>> breaks on the tree today.
>>
>> The reason seems to be that some other patch tweaked with the header
>> files in an unrelated patch, and the static_branch definition that was
>> getting to us in sock.h, is no longer getting there.
>>
>> Including it explicitly fixes it here. I will again pass through a
>> battery of randconfigs on my own, and send you a fix.
>
> Which is one of the reasons we have Rule 1 in Documentation/SubmitChecklist:
>
> 1: If you use a facility then #include the file that defines/declares
>     that facility.  Don't depend on other header files pulling in ones
>     that you use.
>
I understand that. I wasn't saying I am not to blame, just why this 
wasn't catched in any test of mine before.

The fix is on its way.
