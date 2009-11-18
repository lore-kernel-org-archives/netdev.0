From: Caleb Cushing <xenoterracide@gmail.com>
Subject: Re: large packet loss take2 2.6.31.x
Date: Wed, 18 Nov 2009 13:21:19 -0500
Message-ID: <81bfc67a0911181021n1b969565y4a39b181360b5e92@mail.gmail.com>
References: <81bfc67a0911111448q2e7938fcq18adf2454d6bc8f1@mail.gmail.com>
	 <20091112113836.GA7963@ff.dom.local>
	 <81bfc67a0911120546g26627ac5q5860d85f446b29bb@mail.gmail.com>
	 <4AFC5C58.9030207@gmail.com>
	 <81bfc67a0911130825o6d9b93b2he70677157ad889f2@mail.gmail.com>
	 <20091113211640.GA2540@ami.dom.local>
	 <81bfc67a0911180159g45a45675k44ce3f251c6bddea@mail.gmail.com>
	 <20091118135136.GA9224@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Frans Pop <elendil@planet.nl>, Andi Kleen <andi@firstfloor.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932215AbZKRSVV@vger.kernel.org>
In-Reply-To: <20091118135136.GA9224@ff.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Actually, I'm a little bit surprised. Maybe I missed something from
> your previous messages, but I expected something more similar to the
> first wireshark dump, which suggested to me there was only this mtr
> traffic. Now there is a lot more (plus we know it's not all).

probably just me lazy at 5 am? did I do the dump on the router right
so it wasn't showing traffic that's just idling from other computers
(windows likes to make a lot of noise). I could do it by ip...

> So, there is a basic question: can this mtr loss be seen while no
> other traffic is present? After looking into these current dumps I
> doubt. There are e.g. 3 pings unanswered between 09:21:50 and
> 09:21:52 (21:31:34 to 21:31:38 router time), but a lot of tcp
> packets to and from 192.168.1.3, so looks like simply dropped and
> we can guess the reason.

yes. this was at a fairly low traffic time of day. 5am only 2 people
were up, and I was using the other computer during. I've had everyone
actively doing one or more of downloading/uploading/video/voip/gaming
stuff on this network with no noticeable packet loss. if really,
really needed I can probably restrict this network to 2 machines for
the duration of the test.

> Since this patch from the bisection is really limited to this one
> module I doubt we should follow this direction. IMHO it shows the
> test wasn't reproducible enough. Probably the amount and/or kind of
> other traffic really matter. If I'm wrong and missed something again
> let me know. Btw, could you try if changing with ifconfig the
> txqueuelen of desktop's eth0 from 100 to 1000 changes anything
> in this mtr test?

yeah testing it under my known working config first. I'll get back w/ you later.
-- 
Caleb Cushing

http://xenoterracide.blogspot.com
