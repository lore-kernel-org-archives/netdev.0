From: bert hubert <ahu@ds9a.nl>
Subject: Re: [RESEND] tuning linux for high network performance?
Date: Wed, 23 Oct 2002 15:01:01 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20021023130101.GA646@outpost.ds9a.nl>
References: <200210231218.18733.roy@karlsbakk.net> <200210231306.18422.roy@karlsbakk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com,
	Kernel mailing list <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Roy Sigurd Karlsbakk <roy@karlsbakk.net>
Content-Disposition: inline
In-Reply-To: <200210231306.18422.roy@karlsbakk.net>
List-Id: netdev.vger.kernel.org

On Wed, Oct 23, 2002 at 01:06:18PM +0200, Roy Sigurd Karlsbakk wrote:
> > I've got this video server serving video for VoD. problem is the P4 1.8
> > seems to be maxed out by a few system calls. The below output is for ~50
> > clients streaming at ~4.5Mbps. if trying to increase this to ~70, the CPU
> > maxes out.

'50 clients *each* streaming at ~4.4MBps', better make that clear, otherwise
something is *very* broken. Also mention that you have an e1000 card which
does not do outgoing checksumming.

You'd think that a kernel would be able to do 250megabits of TCP checksums
though.

> ...adding the whole profile output - sorted by the first column this time...
> 
> 905182 total                                      0.4741
> 121426 csum_partial_copy_generic                474.3203
>  93633 default_idle                             1800.6346
>  74665 do_wp_page                               111.1086

Perhaps the 'copy' also entails grabbing the page from disk, leading to
inflated csum_partial_copy_generic stats?

Where are you serving from?

Regards,

bert

-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
