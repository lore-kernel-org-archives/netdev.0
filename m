From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [Patch net-next v9 00/11] vxlan: add ipv6 support
Date: Tue, 28 May 2013 09:28:53 +0200
Message-ID: <87vc63a7gq.fsf@nemi.mork.no>
References: <1369628193-14925-1-git-send-email-amwang@redhat.com>
	<87a9ngddfv.fsf@nemi.mork.no> <8761y4dcm7.fsf@nemi.mork.no>
	<20130527.023039.165030551447378095.davem@davemloft.net>
	<1369652446.8181.10.camel@cr0> <87ehcsbmfk.fsf@nemi.mork.no>
	<1369708978.8181.39.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:42999 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758939Ab3E1H3U convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 03:29:20 -0400
In-Reply-To: <1369708978.8181.39.camel@cr0> (Cong Wang's message of "Tue, 28
	May 2013 10:42:58 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <amwang@redhat.com> writes:
> On Mon, 2013-05-27 at 15:07 +0200, Bj=C3=B8rn Mork wrote:
>
>> Give me one reason why I should bother even looking at your next
>> submission.  Just to make it clear:  No comments from me the next ti=
me
>> you post this set only means that I didn't test it.  Which seems
>> likely given your ability to take any feedback at all.
>
> You said "I see that you don't bother listen to advice", this is
> OBVIOUSLY not true, I really did compile with three different configs=
,
> just due a stupid mistake I took my IPV6=3Dn config as IPV6=3Dm confi=
g.

I do understand that mistakes can happen, but this error does not chang=
e
the fact that the patchset was posted without possibly being tested wit=
h
either IPV6=3Dm or IPV6=3Dy. I do find that extremely odd, and really
unexpected. The advice you got was

 Doing different combinations of buildtime and runtime IPv6
 enable/disable is an obvious requirement when you add code which has
 some sort of "if IPv6 is enabled" conditionals.

ref http://permalink.gmane.org/gmane.linux.network/268130

If you never successfully built your patchset with IPv6 support, then
you obviously never attempted any runtime testing at all. It doesn't
matter whether the missing builds were unintentional or not.  If you
followed the advice you got, then you would have noticed.  So, sorry,
it is obvious that you did not follow this advice.  But that doesn't sa=
y
anything about whether you intended to follow it.

But I do take your work that you intended to, and tried to, follow the
advice, and only missed part of it.

Please take some addtional advice: Write a test plan for yourself.

Your explanations show that you missed a number of interesting test
configurations without noticing.  Such things can of course happen, but
it can also be mostly avoided by better structuring of the work.  Havin=
g
a plan and following that is one way.  But there are other ways that
will work as well.  Adding more eyes is another one. These can of cours=
e
be combined.

The point is that you need to do something actively to avoid repeating
this bummer.

> Your conclusion like this one is really offending, and I can't see an=
y
> respect for my work from your reply.

Oh, I do absolutely respect your work.  And I respect you, if that
wasn't clear either.

Please understand that I am testing your code only out of interest in
it.  I am not after you in any way. In fact, I am very interested in
seeing how this goes.  And I do appreciate all the work you've put into
coding this.  That only makes the surprise bigger when you take these
short cuts wrt testing.  I'd really expect that you by revision 9 would
have learned that there is no time to save doing that.  On the
contrary...

Please accept my apologies for the lack of respect for your work in my
reply. I know I am often too harsh in email, and I should work on that.
It has never been my intention to do anything more than helping you get
this code ready and merged.  I should have added a simple appreciation =
in
the initial bug report to make that clearer.

Please continue your good work!  But please, please try to do more
testing yourself before reposting it another time.  You don't want me o=
r
anyone else to find bugs like this one.

> I am sorry for my mistake, and I always welcome for any feedbacks, bu=
t
> just please be with respect. If next time I still see offending reply
> like this, I will just ignore you. Sorry, but this is my right. :(

Of course.  I appreciate that you let me know, and hope my explanation
above is enough to make you understand that the lack of respect in that
reply doesn't reflect my respect for you or your work.


Bj=C3=B8rn
