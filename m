From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: large packet loss take2 2.6.31.x
Date: Sun, 22 Nov 2009 21:50:54 +0100
Message-ID: <20091122205054.GA7361@ami.dom.local>
References: <81bfc67a0911120546g26627ac5q5860d85f446b29bb@mail.gmail.com>
 <4AFC5C58.9030207@gmail.com>
 <81bfc67a0911130825o6d9b93b2he70677157ad889f2@mail.gmail.com>
 <20091113211640.GA2540@ami.dom.local>
 <81bfc67a0911180159g45a45675k44ce3f251c6bddea@mail.gmail.com>
 <20091118135136.GA9224@ff.dom.local>
 <81bfc67a0911181021n1b969565y4a39b181360b5e92@mail.gmail.com>
 <20091118201034.GA3060@ami.dom.local>
 <20091118223851.GA5191@ami.dom.local>
 <81bfc67a0911221135y300841f2i8e78417600528cd5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frans Pop <elendil@planet.nl>, Andi Kleen <andi@firstfloor.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Caleb Cushing <xenoterracide@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755671AbZKVUvK@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <81bfc67a0911221135y300841f2i8e78417600528cd5@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 22, 2009 at 02:35:10PM -0500, Caleb Cushing wrote:
> haven't had time to do a test yet. but would it be of any use for you
> all for me to throw another nic (it'd be a different driver for sure)
> in this box and test that on a problematic kernel? I have some but not
> with me.

Of course it would be useful. Especially if you find new bugs. ;-)
I'm not sure it's the fastest way to diagnose this problem, but if
it's not a problem for you...

Btw, currently I don't consider this dropping means there has to be
a bug. It could be otherwise - a feature... e.g. when a new kernel
can transmit faster (then dropping in some other, slower place can
happen).

Jarek P.

> 
> On Wed, Nov 18, 2009 at 5:38 PM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> > On Wed, Nov 18, 2009 at 09:10:34PM +0100, Jarek Poplawski wrote:
> >> On Wed, Nov 18, 2009 at 01:21:19PM -0500, Caleb Cushing wrote:
> >> > yeah testing it under my known working config first. I'll get back w/ you later.
> >>
> >> Btw, since dropping at hardware (NIC) level seems more likely to me,
> >> could you send 'ethtool eth0', and 'ethtool -S eth0' after such tests
> >> (both sides).
> >
> > Hmm... and 'netstat -s' before and after the test (both sides).
> >
> > Jarek P.
> >
> 
> 
> 
> -- 
> Caleb Cushing
> 
> http://xenoterracide.blogspot.com
