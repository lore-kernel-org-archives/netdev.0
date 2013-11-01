From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] x86: Run checksumming in parallel accross multiple alu's
Date: Fri, 01 Nov 2013 12:45:29 -0700
Message-ID: <1383335129.3042.10.camel@joe-AO722>
References: <201310300525.r9U5Pdqo014902@ib.usersys.redhat.com>
	 <20131030110214.GA10220@localhost.localdomain>
	 <52710B09.6090302@redhat.com>
	 <20131031183003.GC25894@hmsreliant.think-freely.org>
	 <1383320566.1737.0.camel@bwh-desktop.uk.level5networks.com>
	 <20131101160802.GB8467@hmsreliant.think-freely.org>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B73D3@saturn3.aculab.com>
	 <20131101173701.GC8467@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Doug Ledford <dledford@redhat.com>,
	Ingo Molnar <mingo@kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131101173701.GC8467@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-11-01 at 13:37 -0400, Neil Horman wrote:

> I think it would be better if we just did the prefetch here
> and re-addressed this area when AVX (or addcx/addox) instructions were available
> for testing on hardware.

Could there be a difference if only a single software
prefetch was done at the beginning of transfer before
the while loop and hardware prefetches did the rest?
