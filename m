From: Tvrtko Ursulin <tvrtko.ursulin@sophos.com>
Subject: Re: [Regression in 2.6.29] forcedeth doesn't work after resume from hibernation (was: Re: Resume after hibernation regression in 2.6.29)
Date: Fri, 3 Apr 2009 10:23:38 +0000
Message-ID: <200904031123.40390.tvrtko.ursulin@sophos.com>
References: <200903261920.32173.tvrtko@ursulin.net> <200903272109.21259.rjw@sisk.pl> <200903290903.57911.tvrtko@ursulin.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	"linux-pm@lists.linux-foundation.org"
	<linux-pm@lists.linux-foundation.org>,
	kernel list <linux-kernel@vger.kernel.org>,
	Tobias Diedrich <ranma+kernel@tdiedrich.de>,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ed Swierk <eswierk@arastra.com>,
	Arthur Jones <ajones@riverbed.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, stable@kernel.org
To: "Tvrtko A. Ursulin" <tvrtko@ursulin.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pmx1.sophos.com ([213.31.172.16]:38089 "EHLO pmx1.sophos.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755042AbZDCKeX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Apr 2009 06:34:23 -0400
In-Reply-To: <200903290903.57911.tvrtko@ursulin.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 29 March 2009 09:03:57 Tvrtko A. Ursulin wrote:
> On Friday 27 March 2009 20:09:20 Rafael J. Wysocki wrote:
> > I was able to reproduce the problem and identify the commit that broke
> > the resume of forcedeth, which turned out to be:
> >
> > commit cb52deba12f27af90a46d2f8667a64888118a888
> > Author: Ed Swierk <eswierk@arastra.com>
> > Date:   Mon Dec 1 12:24:43 2008 +0000
> >
> >     forcedeth: power down phy when interface is down
> >
> >     Signed-off-by: Ed Swierk <eswierk@arastra.com>
> >     Tested-by: Arthur Jones <ajones@riverbed.com>
> >     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> >     Signed-off-by: David S. Miller <davem@davemloft.net>
> >
> > Since I have no slightest idea of what this commit is supposed to
> > achieve, I can only ask for reverting it.  It reverts cleanly, BTW.
>
> Reverting this fixes it for me as well.
>
> Thanks for your effort!

Would reverting this be a -stable material?

Tvrtko
