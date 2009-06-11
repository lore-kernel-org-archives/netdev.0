From: Martin Fuzzey <mfuzzey@gmail.com>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver configuration.
Date: Thu, 11 Jun 2009 23:39:29 +0200
Message-ID: <4A317991.6030408@gmail.com>
References: <20090610173243.17262.91308.stgit@srv002.fuzzey.net>	 <1244685768.4616.22.camel@deadeye> <4A30A884.9000508@gmail.com>	 <1244732090.2785.12.camel@achroite>	 <alpine.LFD.2.00.0906111159080.31536@xanadu.home>	 <1244739166.2785.52.camel@achroite>	 <alpine.LFD.2.00.0906111333100.31536@xanadu.home>	 <1244744967.2785.61.camel@achroite>	 <alpine.LFD.2.00.0906111452340.31536@xanadu.home>	 <1244748719.2785.72.camel@achroite>	 <alpine.LFD.2.00.0906111605060.31536@xanadu.home> <1244753296.2785.95.camel@achroite>
Reply-To: mfuzzey@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Nicolas Pitre <nico@cam.org>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:38838 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754739AbZFKVja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 17:39:30 -0400
Received: by ewy6 with SMTP id 6so2415716ewy.37
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2009 14:39:31 -0700 (PDT)
In-Reply-To: <1244753296.2785.95.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> It's not my call as to whether your needs are accommodated, and in any
> case I'm not trying to dismiss them.  I'm trying to understand them and
> to suggest what seems like a better solution.
>   
Unfortunately the solution you are proposing (modifying the drivers) has
already been rejected.

The solution here, proposed by Nicolas and implemented by myself, has
already been accepted in principle by David Miller (subject to a clean
implementation and being maintained).

The only argument for your (much more intrusive) solution is that it
will prevent someone later shooting themselves in the foot by using
ethtool to reconfigure the interface to a non working state. But :

1) With the proposed solution there's no need to even have the ethool
binary available.
2) If you're that worried about people shooting themselves in the foot
let's modify the filesystems to refuse deleting files in /bin...

> I'm primarily a driver maintainer and I work with an out-of-tree module
> as well as an in-tree driver.  I've had to deal with many objections in
> the process of submitting that out-of-tree code, and I worked to
> overcome them.  This took several iterations and it was quite
> frustrating at times.  But the result was a better driver.
>   
Yes but it sounds like you're describing the normal review process not
an unwillingless to accept the very idea of your driver.
I have no problem undergoing several iterations (hey that's why I called
it RFC) but I had been hoping for constructive criticism of the
implementation not the principle or the need for this type of module
[which I thought settled in the original thread].

I consider it one of the great strengths of linux that  it can run on
everything from cell phones to super computers and meet the diverse
needs of all those people. I personally have no use for the majority of
the kernel code but I don't see that as as reason it shouldn't be there.

If your view prevails all I will have achieved is the replacement of my
personel 2 line #ifdef hack by 500 lines of "generic" code that no one
else will ever see. Of course in the grand scheme of things that's
insignificant but then I hope people don't complain about embedded
developpers not contributing enough. I did try, really.

Unless anyone wants to discuss the implementation this is my last post
on this subject.

Martin


