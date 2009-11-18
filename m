From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: large packet loss take2 2.6.31.x
Date: Wed, 18 Nov 2009 21:10:34 +0100
Message-ID: <20091118201034.GA3060@ami.dom.local>
References: <81bfc67a0911111448q2e7938fcq18adf2454d6bc8f1@mail.gmail.com>
 <20091112113836.GA7963@ff.dom.local>
 <81bfc67a0911120546g26627ac5q5860d85f446b29bb@mail.gmail.com>
 <4AFC5C58.9030207@gmail.com>
 <81bfc67a0911130825o6d9b93b2he70677157ad889f2@mail.gmail.com>
 <20091113211640.GA2540@ami.dom.local>
 <81bfc67a0911180159g45a45675k44ce3f251c6bddea@mail.gmail.com>
 <20091118135136.GA9224@ff.dom.local>
 <81bfc67a0911181021n1b969565y4a39b181360b5e92@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frans Pop <elendil@planet.nl>, Andi Kleen <andi@firstfloor.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Caleb Cushing <xenoterracide@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932472AbZKRULA@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <81bfc67a0911181021n1b969565y4a39b181360b5e92@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 18, 2009 at 01:21:19PM -0500, Caleb Cushing wrote:
> > So, there is a basic question: can this mtr loss be seen while no
> > other traffic is present? After looking into these current dumps I
> > doubt. There are e.g. 3 pings unanswered between 09:21:50 and
> > 09:21:52 (21:31:34 to 21:31:38 router time), but a lot of tcp
> > packets to and from 192.168.1.3, so looks like simply dropped and
> > we can guess the reason.
> 
> yes. this was at a fairly low traffic time of day. 5am only 2 people
> were up, and I was using the other computer during. I've had everyone
> actively doing one or more of downloading/uploading/video/voip/gaming
> stuff on this network with no noticeable packet loss. if really,
> really needed I can probably restrict this network to 2 machines for
> the duration of the test.

Alas "a fairly low traffic" can have a fairly high surges, so it's not
easy to compare. Anyway, try to check, if it's still available, if
there were any messages from the NIC in syslog etc. during this test
(~09:21:50).

> 
> > Since this patch from the bisection is really limited to this one
> > module I doubt we should follow this direction. IMHO it shows the
> > test wasn't reproducible enough. Probably the amount and/or kind of
> > other traffic really matter. If I'm wrong and missed something again
> > let me know. Btw, could you try if changing with ifconfig the
> > txqueuelen of desktop's eth0 from 100 to 1000 changes anything
> > in this mtr test?
> 
> yeah testing it under my known working config first. I'll get back w/ you later.

Btw, since dropping at hardware (NIC) level seems more likely to me,
could you send 'ethtool eth0', and 'ethtool -S eth0' after such tests
(both sides).

Jarek P.
