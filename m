From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] x86: Run checksumming in parallel accross multiple alu's
Date: Fri, 1 Nov 2013 15:42:46 +0000
Message-ID: <1383320566.1737.0.camel@bwh-desktop.uk.level5networks.com>
References: <201310300525.r9U5Pdqo014902@ib.usersys.redhat.com>
	 <20131030110214.GA10220@localhost.localdomain>
	 <52710B09.6090302@redhat.com>
	 <20131031183003.GC25894@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford@redhat.com>, Ingo Molnar <mingo@kernel.org>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	David Laight <David.Laight@ACULAB.COM>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131031183003.GC25894@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-10-31 at 14:30 -0400, Neil Horman wrote:
[...]
> It
> functions, but unfortunately the performance lost to the completely broken
> branch prediction that this inflicts makes it a non starter:
[...]

Conditional branches are no good but conditional moves might be worth a shot.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
