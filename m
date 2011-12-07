From: Borislav Petkov <bp@alien8.de>
Subject: Re: atl1c: WARNING: at net/sched/sch_generic.c:255 dev_watchdog
Date: Wed, 7 Dec 2011 17:32:08 +0100
Message-ID: <20111207163208.GA1840@x1.osrc.amd.com>
References: <20111206232741.GA5368@x1.osrc.amd.com>
 <CA+5PVA7bM8ZGaCiyZdHcMVccJYh2=bk-gsHLo9ZmBP_SYT208w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Josh Boyer <jwboyer@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+5PVA7bM8ZGaCiyZdHcMVccJYh2=bk-gsHLo9ZmBP_SYT208w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 06, 2011 at 07:12:21PM -0500, Josh Boyer wrote:
> On Tue, Dec 6, 2011 at 6:27 PM, Borislav Petkov <bp@alien8.de> wrote:
> > Hi,
> >
> > this seems like a pretty old issue judging by a quick net search. It
> > still triggers on latest -rc4 here, below the whole trace. I'm willing
> > to test patches :).
> >
> > [14622.820555] atl1c 0000:02:00.0: atl1c: eth0 NIC Link is Up<100 Mbps Full Duplex>
> > [14632.816280] ------------[ cut here ]------------
> > [14632.816314] WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x237/0x240()
> > [14632.816323] Hardware name: 30515QG
> > [14632.816332] NETDEV WATCHDOG: eth0 (atl1c): transmit queue 0 timed out
> 
> Matthew Garrett has a patch to the atl1c driver that changed it's ASPM
> behavior that seemed to help.  Dave Miller applied it, but I don't see
> it in linux-next for some reason.

Yeah, he reverted them due to build issues. I'm not sure they'll be
coming back though, judging by the thread.

Thanks.

-- 
Regards/Gruss,
Boris.
