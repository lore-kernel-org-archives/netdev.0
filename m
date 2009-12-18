From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Fri, 18 Dec 2009 22:51:07 +0100
Message-ID: <20091218215107.GA14946@elte.hu>
References: <4B1D4F29.8020309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Gregory Haskins <gregory.haskins@gmail.com>,
	Avi Kivity <avi@redhat.com>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B1D4F29.8020309@gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Gregory Haskins <gregory.haskins@gmail.com> wrote:

> Hi Linus,
> 
> Please pull AlacrityVM guest support for 2.6.33 from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/ghaskins/alacrityvm/linux-2.6.git
> for-linus
> 
> All of these patches have stewed in linux-next for quite a while now:
> 
> Gregory Haskins (26):

I think it would be fair to point out that these patches have been objected to 
by the KVM folks quite extensively, on multiple technical grounds - as 
basically this tree forks the KVM driver space for which no valid technical 
reason could be offered by you in a 100+ mails long discussion.

(And yes, i've been Cc:-ed to much of that thread.)

The result will IMO be pain for users because now we'll have two frameworks, 
tooling incompatibilities, etc. etc.

I've extended the Cc: for the KVM folks to have a chance to reply. Please try 
_much_ harder to work with the KVM folks instead of ignoring their feedback 
and de-facto forking their project. (and not mentioning any of this in your 
pull request) We should unify, not fracture.

	Ingo
