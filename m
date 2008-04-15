From: jamal <hadi@cyberus.ca>
Subject: Work WAS(Re: Reporting bugs and bisection
Date: Tue, 15 Apr 2008 09:18:36 -0400
Message-ID: <1208265516.4419.125.camel@localhost>
References: <20080413232441.e216a02c.akpm@linux-foundation.org>
	 <20080414072328.GW9785@ZenIV.linux.org.uk>
	 <Xine.LNX.4.64.0804150131300.4160@us.intercode.com.au>
	 <20080414.150105.101568769.davem@davemloft.net>
	 <20080414160513.9f57e5ba.akpm@linux-foundation.org>
	 <20080415045541.GA611@1wt.eu>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, jmorris@namei.org,
	viro@ZenIV.linux.org.uk, david@lang.hm, sclark46@earthlink.net,
	johnpol@2ka.mipt.ru, rjw@sisk.pl, tilman@imap.cc,
	Valdis.Kletnieks@vt.edu, lkml@rtr.ca, jesper.juhl@gmail.com,
	yoshfuji@linux-ipv6.org, jeff@garzik.org,
	linux-kernel@vger.kernel.org, git@vger.kernel.org,
	netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764952AbYDONTB@vger.kernel.org>
In-Reply-To: <20080415045541.GA611@1wt.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2008-15-04 at 06:55 +0200, Willy Tarreau wrote:

> And if Dave speaks about these stats : http://lwn.net/Articles/237768/
> then Al does not even appear in it, which proves your point.

Stats such as those above, while useful, are flawed.
IMO James Morris has (probably more than anybody else) hit on the core
issue. To extend his view: theres more than just code review that
deserves respect. Testing is one. Commenting, not necessarily on code,
but on architecture is another. Documenting. Yes, running sparse or even
Lindent or checkpatch.
In the old/current Linux thinking (pun intended) work equates to
churning code. That thought process derives from Linus actually then
propagates down stream to other folks.
I think the Linus approach is still excellent - but its definition of
"work" is no longer valid. Work must include all these other things
and visible credit is important if the revolution is to continue.

If you look at it from a software engineering or production resource
management, the Linux development model has gotta be one of the most
inefficient[1] - with a reward system geared to developers mostly.
If you want to look it from an investment of time (ROI perspective),
developers get way too much credit riding on everybody elses back.
Why should Mark Lord report another bug to us?
Put yourself in his shoes:
- he is a clever guy who has already worked around the bug. So a proper
fix is only a convinience for him.
- Blessed as he was - he got to do more and more work after reporting.
- he got slapped for claiming he had to go and get lunch and therefore
didnt have time to do more bisect for a bug that wasnt just unique to
his setup.
- he spent a gazillion electrons responding to people and justifying his
stance
- he got no credit for his time whatsoever when the bug was fixed (he
wont be showing up on lwn list).

I think perspective and credit for peoples time needs to change.

cheers,
jamal

[1] With current momentum, theres an infinite resources of developers
and testers and documenters in Linux, i.e
resource management is only valid as a metric if you had finite
resources. So the point i am making is moot - but I do strongly believe
the momentum will dampen if current trend of defining work continues.
