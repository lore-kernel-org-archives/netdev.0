From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [GIT] Networking
Date: Fri, 04 Nov 2011 18:03:42 +0100
Message-ID: <1320426222.3969.121.camel@jlt3.sipsolutions.net>
References: <20111025.063206.2273357152859701628.davem@davemloft.net>
	 <CA+55aFzkZofnUmBOGVvmNKyA0_FApo73xZ7J=aevbHPS_0+xKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>,
	"Guy, Wey-Yi W" <wey-yi.w.guy@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFzkZofnUmBOGVvmNKyA0_FApo73xZ7J=aevbHPS_0+xKQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-10-25 at 12:26 +0000, Linus Torvalds wrote:
> On Tue, Oct 25, 2011 at 12:32 PM, David Miller <davem@davemloft.net> wrote:
> >
> > The most visible thing in here is the reorganization of the drivers
> > under drivers/net.
> 
> Nope, the most visible thing are some new annoying warnings, that seem
> absolutely broken.
> 
> At the very minimum, that WARN_ON(1) should be a WARN_ON_ONCE() or
> something like that. Because showing it over an dover again is not
> helpful.
> 
> Added the people who signed off on the changes to the affected files,
> since they hopefully know why this happens and can fix it..

Sorry for the late reply.

I think this was actually caused by some changes from Ben Greear
"optimising" stuff in net/mac80211/work.c and keeping the wrong channel,
Stanislaw was also looking at this at some point I think. I agree that
it would be good to change to WARN_ON_ONCE(), will do that.

The warning itself has been around forever, but the fact that it
triggers now is probably related to the channel work & band switches.

johannes
