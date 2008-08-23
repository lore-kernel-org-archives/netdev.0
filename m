From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [bisected] Weird sysctl regression
Date: Sat, 23 Aug 2008 19:13:49 +0200
Message-ID: <87ljynd582.fsf@natisbad.org>
References: <87fxoyal9j.fsf@natisbad.org>
	<20080823084936.GK28946@ZenIV.linux.org.uk>
	<87wsi7en1m.fsf@natisbad.org>
	<20080823170248.GL28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moog.chdir.org ([88.191.42.160]:52832 "EHLO moog.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752589AbYHWRPG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Aug 2008 13:15:06 -0400
In-Reply-To: <20080823170248.GL28946@ZenIV.linux.org.uk> (Al Viro's message of
	"Sat, 23 Aug 2008 18:02:48 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Al Viro <viro@ZenIV.linux.org.uk> writes:

> On Sat, Aug 23, 2008 at 06:03:33PM +0200, Arnaud Ebalard wrote:
>> > Can you reproduce it on mainline kernel
>> 
>> All Linux 2.6.26 (initial and stable releases) are not affected. I am
>> currently running 2.6.26.3.
>> 
>> > or bisect between the mainline and net-2.6 if mainline is OK?
>> 
>> As I wrote in my previous email, bisecting net-2.6 lead me to 
>> 9043476f726802f4b00c96d0c4f418dde48d1304 ([PATCH] sanitize proc_sysctl)
>> which is in the middle of a set of fs/sysctl related patches. 
>> 
>> I think I am missing the point on what you want me to do. Can you
>> clarify? 
>
> Check the tip of Linus' git tree.  Or, at least, something like -rc4.

I already tested 26.27-rc4 and even net-next-2.6 (recently released one
based on rc4 with some bug fixes). Problem is still here.

I did not already tested tip of Linus' git tree but can do it on Monday.

This might be completely unrelated but while looking at others commits
around previous one, I saw bd7b1533cd6a68c734062aa69394bec7e2b1718e
([PATCH] sysctl: make sure that /proc/sys/net/ipv4 appears before per-ns
ones). Does IPv6 need the same kind of trick ?

Cheers,

a+
