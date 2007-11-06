From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Endianness problem with u32 classifier hash masks
Date: Tue, 06 Nov 2007 21:28:03 +0100
Message-ID: <4730CE53.30602@o2.pl>
References: <20071105091231.GA1933@ff.dom.local>	 <1194267561.2987.141.camel@localhost.localdomain>	 <20071105135246.GB1933@ff.dom.local> <1194271589.4438.113.camel@localhost>	 <1194283888.2987.186.camel@localhost.localdomain> <472F85F0.8060205@o2.pl>	 <1194301667.4430.28.camel@localhost> <472FAF29.7050704@o2.pl>	 <1194336542.3305.33.camel@rad.rendec.ines.ro>	 <1194356071.4444.23.camel@localhost>  <20071106142558.GC1666@ff.dom.local>	 <1194360226.4444.39.camel@localhost> <1194368416.2987.218.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: Radu Rendec <radu.rendec@ines.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:60884 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755501AbXKFUPC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Nov 2007 15:15:02 -0500
In-Reply-To: <1194368416.2987.218.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Radu Rendec wrote, On 11/06/2007 06:00 PM:

> On Tue, 2007-11-06 at 09:43 -0500, jamal wrote:
>> On Tue, 2007-06-11 at 15:25 +0100, Jarek Poplawski wrote:
>>
>>> Yes, it saves one htonl() on the slow path!
>> Would it feel better to say grew down exponentially from version 1 to
>> 3? ;->


Sure, but I felt much better after this:

> Actually I'm not impatient at all, because the shaping machine at the
> ISP where I work is already patched with my original patch, and cpu
> usage has gone from 100% to 8% after implementing hashes ;->
 

I'm not so lucky to see this code working, so I didn't expect earlier
this place could be so meaningful. As a matter of fact I've thought
Jamal exaggerates about this fast path... Now, I try to understand
why it didn't come out earlier. Anyway, Radu - my congratulations!

>>>> Please give yourself a little pat on the back for me.
>>> Wait a minute! Don't forget to take a picture or something!
>> He needs the other arm for balance;-> so unless someone else takes the
>> photo, i would say that should he be successful taking the photo, that
>> achievement itself needs a double-self-pat-on-the-back (which i am going
>> to say if he can also take a photo of needs to go on some records book)
> 
> I'm sorry to disappoint you, guys, but most probably I'll pat myself on
> the back here at work, after I get enthusiastic about the patches. So my
> fellow colleagues will take the picture for me. If I get really
> enthusiastic, then I'll have my both arms available for patting :)


Alas, I don't take pictures either, but, it seems, any way should be
good if it's visible for whom are you patted by!

Cheers,
Jarek P.
