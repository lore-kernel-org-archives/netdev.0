From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] x86: Run checksumming in parallel accross multiple alu's
Date: Fri, 1 Nov 2013 16:18:50 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B73D3@saturn3.aculab.com>
References: <201310300525.r9U5Pdqo014902@ib.usersys.redhat.com> <20131030110214.GA10220@localhost.localdomain> <52710B09.6090302@redhat.com> <20131031183003.GC25894@hmsreliant.think-freely.org> <1383320566.1737.0.camel@bwh-desktop.uk.level5networks.com> <20131101160802.GB8467@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Doug Ledford" <dledford@redhat.com>,
	"Ingo Molnar" <mingo@kernel.org>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Neil Horman" <nhorman@tuxdriver.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20131101160802.GB8467@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> How would you suggest replacing the jumps in this case?  I agree it would be
> faster here, but I'm not sure how I would implement an increment using a single
> conditional move.

I think you need 3 instructions, move a 0, conditionally move a 1
then add. I suspect it won't be a win!

If you do 'win' it is probably very dependent on how the instructions
get scheduled onto the execution units - which will probably make
it very cpu type dependant.

	David
