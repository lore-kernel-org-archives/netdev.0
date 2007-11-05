From: Radu Rendec <radu.rendec@ines.ro>
Subject: Re: Endianness problem with u32 classifier hash masks
Date: Mon, 05 Nov 2007 19:31:28 +0200
Message-ID: <1194283888.2987.186.camel@localhost.localdomain>
References: <1193939701.2987.82.camel@localhost.localdomain>
	 <472B5EF1.4020206@o2.pl> <1194045830.4438.21.camel@localhost>
	 <472D06B2.9040402@o2.pl> <472D0B1C.7000209@o2.pl> <472D128B.8030704@o2.pl>
	 <472D1DC2.9000106@o2.pl> <1194220693.4438.75.camel@localhost>
	 <20071105091231.GA1933@ff.dom.local>
	 <1194267561.2987.141.camel@localhost.localdomain>
	 <20071105135246.GB1933@ff.dom.local>  <1194271589.4438.113.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@o2.pl>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from NAT-173-Unkn.Local.iNES.RO ([80.86.100.173]:48801 "EHLO
	blade.ines.ro" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750882AbXKERd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 12:33:27 -0500
In-Reply-To: <1194271589.4438.113.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-11-05 at 09:06 -0500, jamal wrote:
> On Mon, 2007-05-11 at 14:52 +0100, Jarek Poplawski wrote:
> 
...
> > If we manage to convince Jamal, IMHO a patch to something current like
> > 2.6.24-rc1-git14 (or maybe -rc2 soon), should suffice (plus some
> > options to diff to get function names etc. eg.: diff -Nurp). Try with
> > Documentation/SubmittingPatches. Git isn't necessary at all. And don't
> > forget about a changelog.
> 
> That code hasnt changed at all in a few years, so even against
> 2.6.24-rc1 should be fine and can be applied cleanly to Daves net-2.6.
> Radu, please refer to my earlier email on things to try.

Ok, silly procmail rules + threaded view = bad idea. I just didn't see
your last messages earlier when I replied. Sorry!

But still, Jamal, I need more explanations on what you meant by "cutdown
on the conversion in u32_change()". And, before proceeding, I'd like to
see your reply to Jarek's last email (at 15:49 +0100) about not getting
0xff in the end.

Jarek, because I have to test anyway, I'll include ffs(mask) in my patch
and have it tested too.

I already have a clone of Dave's net-2.6 tree, so it shouldn't be such a
big effort to use git after all. I can also make the patch against
2.6.24-rc1, so please tell me which is more convinient for you.

Cheers,
Radu Rendec


