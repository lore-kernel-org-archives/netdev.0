From: Sergei Shtylyov <sshtylyov@mvista.com>
Subject: Re: [PATCH] netdev: fix compile issues for !CONFIG_PCI in 3c59x
Date: Mon, 26 Mar 2012 18:55:10 +0400
Message-ID: <4F70834E.3000308@mvista.com>
References: <1332724306-8799-1-git-send-email-paul.gortmaker@windriver.com> <CAP=VYLpOJOueFfzxFGCu5cKQ9--F8CqC5JWjBxej7u=8z3K0xQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: klassert@mathematik.tu-chemnitz.de, netdev@vger.kernel.org,
	linux-mips@linux-mips.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: Paul Gortmaker <paul.gortmaker@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:48042 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932444Ab2CZO4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 10:56:12 -0400
Received: by bkcik5 with SMTP id ik5so4071261bkc.19
        for <netdev@vger.kernel.org>; Mon, 26 Mar 2012 07:56:11 -0700 (PDT)
In-Reply-To: <CAP=VYLpOJOueFfzxFGCu5cKQ9--F8CqC5JWjBxej7u=8z3K0xQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/26/2012 05:38 PM, Paul Gortmaker wrote:

>> I hate to add in more #ifdef CONFIG_PCI but there are already
>> quite a few in this driver, and it seems like it hasn't been
>> built with CONFIG_PCI set to off in quite some time.

> Actually, please scrap this patch.  The uglyness of more ifdefs
> made me look at it again.  It should be do-able in a cleaner way
> with stubs, and it appears this may even be similar to an old fail
> from the past:

> http://lkml.indiana.edu/hypermail/linux/kernel/1107.3/00109.html

    Also, see this patch:

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=0da0ead90122578ef6e4afba9ba4bcd3455fd8e8

    The driver patch this was done for is still in the -mm tree after all these 
years.:-)

> I'll dig into it some more and follow up.

    I thought I addressed all issues with compilation of this driver with 
CONFIG_PCI=n. Apparently not, and some seem to have accumulated over time...

> Thanks,
> Paul.

WBR, Sergei
