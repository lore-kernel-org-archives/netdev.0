From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH RESEND] uts: Set default hostname to "localhost", rather
 than "(none)"
Date: Mon, 11 Apr 2011 08:12:40 -0700
Message-ID: <BANLkTinVGTOAsxG1CiJO1mSGRxBSNP5P4Q@mail.gmail.com>
References: <20110411050155.GA2507@feather> <20110411080254.403d3166@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Josh Triplett <josh@joshtriplett.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110411080254.403d3166@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 11, 2011 at 8:02 AM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
>
> It makes sense but this behavior has existed so long in Linux
> that some distro might actually be depending on it.

Yes. Also, quite frankly, I do _not_ think that "localhost" is in any
way a more correct hostname.

I'd rather have an obviously invalid hostname for a machine that
hasn't been set up correctly than one that might work by random
chance.

                                    Linus
