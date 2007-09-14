From: "David Madsen" <david.madsen@gmail.com>
Subject: Re: r8169: slow samba performance
Date: Thu, 13 Sep 2007 18:31:25 -0700
Message-ID: <ec7e30370709131831v3ea1287ag55c9de7052e427b9@mail.gmail.com>
References: <ec7e30370709090044m55efbbcl3cb9e9489f2d5e6e@mail.gmail.com>
	 <20070909153312.GA29586@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.185]:25197 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118AbXINBb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2007 21:31:27 -0400
Received: by fk-out-0910.google.com with SMTP id z23so635872fkz
        for <netdev@vger.kernel.org>; Thu, 13 Sep 2007 18:31:25 -0700 (PDT)
In-Reply-To: <20070909153312.GA29586@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > I noticed a somewhat significant difference between patch #0002 and a
> > busy wait loop with ndelay(10). Write performance was equivalent in
> > both cases as should be the case.  Read perfomance for me maxed out
>
> Do you have some (gross) figure for the write performance ?

Write performance was quite high, around 650-700 megabit no doubt due
to caching behavior on the server, and it was similar in both cases.
I believe the machine with the r8169 was CPU bound at this point or it
probably would have been even higher.

Sorry for the slow response, your reply ended up buried in a deluge of
email and I just dug it out.  I'll give these other patches a spin in
the next couple days when I get a chance and see if things improve.

--David Madsen
