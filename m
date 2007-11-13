From: Theodore Tso <tytso@mit.edu>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 13:55:47 -0500
Message-ID: <20071113185547.GC25824@thunk.org>
References: <20071113031553.3c7b5c16.akpm@linux-foundation.org> <20071113.033946.114918709.davem@davemloft.net> <20071113034916.2556edd7.akpm@linux-foundation.org> <20071113.035824.40509981.davem@davemloft.net> <20071113041259.79c9a8c5.akpm@linux-foundation.org> <20071113134029.GA30978@elte.hu> <4739AFE0.20705@rtr.ca> <40f323d00711130752k19cab8eauc3456721274b3267@mail.gmail.com> <20071113171356.GA25824@thunk.org> <4739DFF8.3090702@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benoit Boissinot <bboissin@gmail.com>, Mark Lord <liml@rtr.ca>,
	Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, protasnb@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: Larry Finger <larry.finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from thunk.org ([69.25.196.29]:37435 "EHLO thunker.thunk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755947AbXKMS4V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 13:56:21 -0500
Content-Disposition: inline
In-Reply-To: <4739DFF8.3090702@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 13, 2007 at 11:33:44AM -0600, Larry Finger wrote:
> I'm very encouraged to read of your expanded testing efforts. As a
> bcm43xx developer, Ubuntu has been our problem distro, mostly
> because your standard kernels have debugging turned off for bcm43xx.
> When a Ubuntu user reports a problem and we ask for the relevant
> output from dmesg, they have no information. I ask two things of all
> distros: (1) Turn on debugging - we don't spam the logs that badly,
> and (2) forward any bugs found by your testing to the maintainer,
> and/or the bcm43xx mailing list.

Heh. I hadn't enabled CONFIG_BCM43XX_DEBUG myself, but I just changed
it for my next kernel build.  This is a slightly different issue,
which is that sometimes _DEBUG options shouldn't be turned on by
default (because they really trash performance and bloat log size),
and sometimes they are painless to turn on and don't cost much.

If that is the case, I'd suggest removing the option and just making
it compiled in by default with a run-time option to enable it.

   	       	  	       	 	  - Ted


   	      

