From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] fib_trie: Fix potential null pointer dereference
Date: Sun, 07 Jun 2015 09:36:19 -0700
Message-ID: <55747303.4050809@gmail.com>
References: <1433590553-4672-1-git-send-email-firogm@gmail.com> <1433592304.1895.73.camel@edumazet-glaptop2.roam.corp.google.com> <20150607060129.GA9265@firo> <alpine.DEB.2.02.1506070835310.2108@localhost6.localdomain6> <20150607131924.GA16087@firo> <alpine.DEB.2.10.1506071520410.2716@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, wharms@bfs.de
To: Julia Lawall <julia.lawall@lip6.fr>, Firo Yang <firogm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:34055 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751359AbbFGQgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2015 12:36:23 -0400
In-Reply-To: <alpine.DEB.2.10.1506071520410.2716@hadrien>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/2015 06:23 AM, Julia Lawall wrote:
>>> I think that many people would make the same mistake when looking at the
>>> code.  The change doesn't seem to hurt anything?
>> Actually, yes. But it does imporve nothing but coding style.
>> I think Alexander's code style make function more compact is also a
>> good code style. So, just keep it original.
>
> Still it makes noise when other people look at the code and find that it
> looks odd.  Removing the false positive in smatch won't completely help,
> because people could look at the code for other reasons.

I agree.  The patch is good.  My only comment was about the patch 
description.  You are fixing a coding style issue reported by smatch, 
not a NULL pointer dereference.  This is a code clean-up rather than a 
fix, but still the patch is just as useful.

While you are at it you could probably also incorporate the suggestion 
from Walter as that helps to improve the readability further.

- Alex
