From: Jan Kara <jack@suse.cz>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 18:49:07 +0100
Message-ID: <20071113174907.GB13733@atrey.karlin.mff.cuni.cz>
References: <32209efe0711122242m3a5f081asf1c11a38b24db10c@mail.gmail.com> <20071113031553.3c7b5c16.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Natalie Protasevich <protasnb@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-ide-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20071113031553.3c7b5c16.akpm@linux-foundation.org>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > FILE SYSTEMS=======================================================
> > 
> > ext4: delalloc space accounting problem drops data
> > http://bugzilla.kernel.org/show_bug.cgi?id=9329
> > Kernel: 2.6.24-rc1
> No response from developers
  Actually, there has been a response (Eric asked in mailing list and
created a bug and got answer to the mailing list):
http://marc.info/?l=linux-ext4&m=119454449014728&w=2

> > POSIX Access Control Lists cause bogus file system check errors
> > http://bugzilla.kernel.org/show_bug.cgi?id=9241
> > Kernel: 2.6.23.1
> 
> Andreas did some work, seemed to lose interest.
  As I read the bug it seems that the cause was a filesystem with errors
(which were in ACL's and thus kernel didn't boot only with ACL's
enabled) and fsck fixed the problem... I would close this one as
invalid (OK, I know the filesystem had to be corrupted somehow but
unless this is at least occasionally reproducible, there's low chance of
finding the bug).

								Honza

-- 
Jan Kara <jack@suse.cz>
SuSE CR Labs
