From: Stefan Schmidt <s.schmidt@mcbone.net>
Subject: (solved) Re: Fw: 2.6.11-mm2 weird ethernet RTTs
Date: Sat, 19 Mar 2005 14:54:12 +0100
Message-ID: <20050319135412.GA5134@giscard.mcbone.net>
References: <20050317115254.4f8e462a.akpm@osdl.org> <20050318091140.GE30259@giscard.mcbone.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050318091140.GE30259@giscard.mcbone.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Mar 18, 2005 at 10:11:40AM +0100, Stefan Schmidt wrote:
> > I'm not aware of any changes which would cause this.  Generally -mm's
> > networking is the same as Linus's.  Could you test Linus's latest tree?
> > (-rc1 should be out very soon, so that would be appropriate)
> 2.6.10-mm1 was the kernel i ran before 2.6.11-mm2 on this machine which
> did not show this behaviour. I will try the latest vanilla as soon as
> i'm in office. Perhaps this problem is e1000-driver inflicted, i am
> using it as a module - will try latest vanilla with the same setup.

I tried booting 2.6.12-rc1. It hung 50% of the time intermittent with a
harddisk DMA timeout due to some weird things on irq 117 and the other
time a kernel BUG in e1000 was triggered for which i will open another
thread. Anyway i saw in a wink that ide_cd reported to CD-ROM drive to
do weird things and removed the thing. The system went up fine after
that and ping RTTs were back to what i experienced before that whole
story. I labeled the delinquent device 'CD-ROM drive of doom' and just
assumed that it behave so bad on the other IDE bus (not the one the HD
is attached too) that the IDE-Controller was hogged up with handling
that bus and either generated some interrupts by itself or was not able
to respond to them properly anymore. The CD-ROM drive also gives
interesting rattling noises when shaken - its a LG 52x, don't have the
model # at hand now.

	Stefan
-- 
A day without fusion is like a day without sunshine.
