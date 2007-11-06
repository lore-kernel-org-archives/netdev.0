From: Radu Rendec <radu.rendec@ines.ro>
Subject: Re: Endianness problem with u32 classifier hash masks
Date: Tue, 06 Nov 2007 19:00:16 +0200
Message-ID: <1194368416.2987.218.camel@localhost.localdomain>
References: <20071105091231.GA1933@ff.dom.local>
	 <1194267561.2987.141.camel@localhost.localdomain>
	 <20071105135246.GB1933@ff.dom.local> <1194271589.4438.113.camel@localhost>
	 <1194283888.2987.186.camel@localhost.localdomain> <472F85F0.8060205@o2.pl>
	 <1194301667.4430.28.camel@localhost> <472FAF29.7050704@o2.pl>
	 <1194336542.3305.33.camel@rad.rendec.ines.ro>
	 <1194356071.4444.23.camel@localhost>  <20071106142558.GC1666@ff.dom.local>
	 <1194360226.4444.39.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@o2.pl>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from NAT-173-Unkn.Local.iNES.RO ([80.86.100.173]:51578 "EHLO
	blade.ines.ro" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751156AbXKFRCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 12:02:34 -0500
In-Reply-To: <1194360226.4444.39.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-11-06 at 09:43 -0500, jamal wrote:
> On Tue, 2007-06-11 at 15:25 +0100, Jarek Poplawski wrote:
> 
> > Yes, it saves one htonl() on the slow path!
> 
> Would it feel better to say grew down exponentially from version 1 to
> 3? ;->

Not only it saves one htonl(), but also keeps the code readable :)
Computing offsets within the rtnetlink response skb and applying htonl()
there is quite tricky and might get broken if RTA_PUT() is changed.
Unfortunately I spent about an hour figuring out how to do that :))

The bad news is that today I haven't got the chance to work on the two
patches. But the good news is that I managed to finish the (urgent) task
that had been assigned to me at work, and tomorrow I will be able to
work on the kernel and test it leisurely.

> > > Please give yourself a little pat on the back for me.
> > 
> > Wait a minute! Don't forget to take a picture or something!
> 
> He needs the other arm for balance;-> so unless someone else takes the
> photo, i would say that should he be successful taking the photo, that
> achievement itself needs a double-self-pat-on-the-back (which i am going
> to say if he can also take a photo of needs to go on some records book)

I'm sorry to disappoint you, guys, but most probably I'll pat myself on
the back here at work, after I get enthusiastic about the patches. So my
fellow colleagues will take the picture for me. If I get really
enthusiastic, then I'll have my both arms available for patting :)

Cheers,

Radu

