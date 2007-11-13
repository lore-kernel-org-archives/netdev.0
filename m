From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 04:32:07 -0800 (PST)
Message-ID: <20071113.043207.44732743.davem@davemloft.net>
References: <20071113034916.2556edd7.akpm@linux-foundation.org>
	<20071113.035824.40509981.davem@davemloft.net>
	<20071113041259.79c9a8c5.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: protasnb@gmail.com, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org, alsa-devel@alsa-project.org,
 linux-ide@vger.kernel.org, linux-pcmcia@lists.infradead.org,
 linux-input@atrey.karlin.mff.cuni.cz, bugme-daemon@bugzilla.kernel.org
To: akpm@linux-foundation.org
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
In-Reply-To: <20071113041259.79c9a8c5.akpm@linux-foundation.org>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 13 Nov 2007 04:12:59 -0800

> On Tue, 13 Nov 2007 03:58:24 -0800 (PST) David Miller <davem@davemloft.net> wrote:
> 
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Date: Tue, 13 Nov 2007 03:49:16 -0800
> > 
> > > Do you believe that our response to bug reports is adequate?
> > 
> > Do you feel that making us feel and look like shit helps?
> 
> That doesn't answer my question.
> 
> See, first we need to work out whether we have a problem.  If we do this,
> then we can then have a think about what to do about it.
> 
> I tried to convince the 2006 KS attendees that we have a problem and I
> resoundingly failed.  People seemed to think that we're doing OK.
> 
> But it appears that data such as this contradicts that belief.
> 
> This is not a minor matter.  If the kernel _is_ slowly deteriorating then
> this won't become readily apparent until it has been happening for a number
> of years.  By that stage there will be so much work to do to get us back to
> an acceptable level that it will take a huge effort.  And it will take a
> long time after that for the kerel to get its reputation back.
> 
> So it is important that we catch deterioration *early* if it is happening.

You tell me what I should spend my time working on, and I promise to
do it OK? :-)

For example, if I have a choice between a TCP crash just about anyone
can hit and some obscure issue only reported with some device nearly
nobody has, which one should I analyze and work on?

That's the problem.  All of us prioritize and it means the chaff
collects at the bottom.  You cannot fix that except by getting more
bug fixers so that the chaff pile has a chance to get smaller.

Luckily if the report being ignored isn't chaff, it will show up again
(and again and again) and this triggers a reprioritization because not
only is the bug no longer chaff, it also now got a lot of information
tagged to it so it's a double worthwhile investment to work on the
problem.

I think a lot of bugs that "aren't getting looked at" are simply
sitting in some early stage of this process.
