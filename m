From: jamal <hadi@cyberus.ca>
Subject: Re: Endianness problem with u32 classifier hash masks
Date: Mon, 05 Nov 2007 17:27:47 -0500
Message-ID: <1194301667.4430.28.camel@localhost>
References: <1193939701.2987.82.camel@localhost.localdomain>
	 <472B5EF1.4020206@o2.pl> <1194045830.4438.21.camel@localhost>
	 <472D06B2.9040402@o2.pl> <472D0B1C.7000209@o2.pl> <472D128B.8030704@o2.pl>
	 <472D1DC2.9000106@o2.pl> <1194220693.4438.75.camel@localhost>
	 <20071105091231.GA1933@ff.dom.local>
	 <1194267561.2987.141.camel@localhost.localdomain>
	 <20071105135246.GB1933@ff.dom.local> <1194271589.4438.113.camel@localhost>
	 <1194283888.2987.186.camel@localhost.localdomain>  <472F85F0.8060205@o2.pl>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Radu Rendec <radu.rendec@ines.ro>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:15828 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045AbXKEW1x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 17:27:53 -0500
Received: by wa-out-1112.google.com with SMTP id v27so2175349wah
        for <netdev@vger.kernel.org>; Mon, 05 Nov 2007 14:27:52 -0800 (PST)
In-Reply-To: <472F85F0.8060205@o2.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-05-11 at 22:06 +0100, Jarek Poplawski wrote:
> Radu Rendec wrote, On 11/05/2007 06:31 PM:

> > But still, Jamal, I need more explanations on what you meant by "cutdown
> > on the conversion in u32_change()". 

I meant that it didnt seem necessary to me you have to do the conversion
back and forth of the hmask as you do in the u32_change(). The basis of
the patch i posted - which is based on yours - is to remove that change.
If that doesnt work, please just send your patch as is and we can think
of optimization later.

> > And, before proceeding, I'd like to
> > see your reply to Jarek's last email (at 15:49 +0100) about not getting
> > 0xff in the end.

On paper i get the same result with the new or old scheme for the bucket selection.
As i stated on the patch - i never did test the theory.

> Radu, as far as I know Jamal (from reading) he most probably is busy with
> some conference! 

I actually have a day job and have to show up and meet TheMan, Jarek;->
Most of the days at work, i dont have time to look at external email
account - but you can bet all horses you own i will get back to you
within a few hours if you CC me on email.

> Since these patches aren't so big I think you could
> try Jamal's at first, and if it doesn't work, and nothing new from Jamal
> in the meantime, resend your version. Cutdown in u32_change() seems to
> add more to the fastpath, but maybe Jamal thinks about something else.

I mean do most work on slow/config path.

> > Jarek, because I have to test anyway, I'll include ffs(mask) in my patch
> > and have it tested too.

Lets have two patches - one for the le/be bucket selection and another
for ffs.

cheers,
jamal

