From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 23:09:09 +0100
Message-ID: <200711132309.11874.rjw@sisk.pl>
References: <20071113.033946.114918709.davem@davemloft.net> <20071113184902.GG17785@parisc-linux.org> <4739F2DD.5050802@rtr.ca>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Matthew Wilcox <matthew@wil.cx>,
 Ingo Molnar <mingo@elte.hu>,
 alsa-devel@alsa-project.org,
 netdev@vger.kernel.org,
 linux-pcmcia@lists.infradead.org,
 linux-kernel@vger.kernel.org,
 protasnb@gmail.com,
 linux-ide@vger.kernel.org,
 bugme-daemon@bugzilla.kernel.org,
 linux-input@atrey.karlin.mff.cuni.cz,
 Andrew Morton <akpm@linux-foundation.org>,
 David Miller <davem@davemloft.net>
To: Mark Lord <liml@rtr.ca>
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
In-Reply-To: <4739F2DD.5050802@rtr.ca>
Content-Disposition: inline
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

On Tuesday, 13 of November 2007, Mark Lord wrote:
> Matthew Wilcox wrote:
> > On Tue, Nov 13, 2007 at 01:43:53PM -0500, Mark Lord wrote:
> >
> >> mkdir t
> >> cd t
> >> git clone 
> >> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
> >> (wait half an hour)
> >> /usr/bin/du -s linux-2.6
> >> 522732  linux-2.6
> > 
> > You're assuming that everything in linux-2.6 was downloaded; that's
> > not true.  Everything in linux-2.6/.git was downloaded; but then you do a
> > checkout which happens to approximately double the size of the linux-2.6
> > directory. 
> ..
> 
> Ah, I wondered why it took only half an hour to download.
> 
> ..
> > When you compare it to the 60MB tarballs that are published, it's really
> > not that bad.
> ..
> 
> The tarballs I download are only 45MB.

You clone the git repo once.  Afterwards, you only update it and that usually
doesn't take that much time and a little effort.

Greetings,
Rafael
