From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 15/15] ptp: PTP_1588_CLOCK_PCH depends on x86
Date: Tue, 14 May 2013 19:12:34 +0100
Message-ID: <20130514181234.GH31561@decadent.org.uk>
References: <1367936303-13386-1-git-send-email-jslaby@suse.cz>
 <1367936303-13386-15-git-send-email-jslaby@suse.cz>
 <20130507192938.GA3599@netboy>
 <51924819.3060907@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Richard Cochran <richardcochran@gmail.com>,
	Jiri Slaby <jirislaby@gmail.com>, linux-kernel@vger.kernel.org,
	Jeff Mahoney <jeffm@suse.com>, netdev@vger.kernel.org
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51924819.3060907@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 14, 2013 at 04:20:09PM +0200, Jiri Slaby wrote:
> On 05/07/2013 09:29 PM, Richard Cochran wrote:
> > On Tue, May 07, 2013 at 04:18:23PM +0200, Jiri Slaby wrote:
> >> From: Jeff Mahoney <jeffm@suse.com>
> >>
> >> The PCH EG20T is only compatible with Intel Atom processors so it
> >> should depend on x86.
> > 
> > This patch has been submitted before,
> > 
> >    https://patchwork.kernel.org/patch/2069071/
> > 
> > and at that time the reaction was that it is good to have drivers
> > cross-compiled, if only for code quality reasons.
> 
> Hmm, then it depends whether the kernel is for users or for developers.
> I, as a user, do not really want to compile drivers with allmodconfig
> which I have no way to load/use.
> 
> And allmodconfig is basically what we, users (SUSE distributors in this
> case) do. So having this driver being built makes our life harder (in
> the meaning we have to have specific rules about disabling unwanted
> drivers from configs).

Wearing my Debian hat, I agree with this.  Perhaps we could define a
CONFIG_BUILD_TEST symbol for people who want to do that, and then
make drivers for hardware that's only found in x86 systems (for
example) depend on X86 || BUILD_TEST.

Ben.

> And, developers should have a testbed where they build 32bit configs.
> And we actually have that for -next AFAIU.

-- 
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camus
