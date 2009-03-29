From: "Tvrtko A. Ursulin" <tvrtko@ursulin.net>
Subject: Re: [Regression in 2.6.29] forcedeth doesn't work after resume from hibernation (was: Re: Resume after hibernation regression in 2.6.29)
Date: Sun, 29 Mar 2009 09:03:57 +0100
Message-ID: <200903290903.57911.tvrtko@ursulin.net>
References: <200903261920.32173.tvrtko@ursulin.net> <200903271255.36429.rjw@sisk.pl> <200903272109.21259.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Pavel Machek <pavel@ucw.cz>, linux-pm@lists.linux-foundation.org,
	kernel list <linux-kernel@vger.kernel.org>,
	Tobias Diedrich <ranma+kernel@tdiedrich.de>,
	Ayaz Abdulla <aabdulla@nvidia.com>, netdev@vger.kernel.org,
	Ed Swierk <eswierk@arastra.com>,
	Arthur Jones <ajones@riverbed.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753890AbZC2IEi@vger.kernel.org>
In-Reply-To: <200903272109.21259.rjw@sisk.pl>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 27 March 2009 20:09:20 Rafael J. Wysocki wrote:
> I was able to reproduce the problem and identify the commit that broke the
> resume of forcedeth, which turned out to be:
>
> commit cb52deba12f27af90a46d2f8667a64888118a888
> Author: Ed Swierk <eswierk@arastra.com>
> Date:   Mon Dec 1 12:24:43 2008 +0000
>
>     forcedeth: power down phy when interface is down
>
>     Signed-off-by: Ed Swierk <eswierk@arastra.com>
>     Tested-by: Arthur Jones <ajones@riverbed.com>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
> Since I have no slightest idea of what this commit is supposed to achieve,
> I can only ask for reverting it.  It reverts cleanly, BTW.

Reverting this fixes it for me as well.

Thanks for your effort!

Tvrtko
