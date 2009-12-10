From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: + net-ipv4-tcpc-fix-warning.patch added to -mm tree
Date: Thu, 10 Dec 2009 08:48:30 -0500
Message-ID: <4B20FC2E.7050809@gmail.com>
References: <200912090045.nB90jTaO010647@imap1.linux-foundation.org>	<4B1F0151.10903@gmail.com> <20091208180801.88be28ba.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.211.176]:51481 "EHLO
	mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487AbZLJNs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 08:48:26 -0500
Received: by ywh6 with SMTP id 6so7096236ywh.4
        for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 05:48:33 -0800 (PST)
In-Reply-To: <20091208180801.88be28ba.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Tue, 08 Dec 2009 20:45:53 -0500
> William Allen Simpson <william.allen.simpson@gmail.com> wrote:
>> I didn't have this warning, how in the world do you get it?
> 
> Used gcc-4.0.2.  They re-randomise the warnings with each release I think.
> 
Using gcc-4.4.1 here, and the usual 'make -s -j4 vmlinux'.


>> This is what David calls my "anal" coding style.  I check everything,
>> because someday somebody else might make a change, and it's important
>> that such problems be detected.  In this case, I assume the compiler
>> will compile them out or it would have no effect, and commented that
>> it should be impossible.
>>
>> Your test should probably be TCP_MSS_DEFAULT < TCP_COOKIE_PAIR_SIZE
> 
> I'd say just delete it ;)
> 
Well, David said he would, but nothing seems to have happened, so I'll
send a short patch in my next message.
