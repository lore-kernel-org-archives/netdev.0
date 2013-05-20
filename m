From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [PATCH 15/15] ptp: PTP_1588_CLOCK_PCH depends on x86
Date: Mon, 20 May 2013 22:31:02 +0000
Message-ID: <02874ECE860811409154E81DA85FBB58564EC215@ORSMSX104.amr.corp.intel.com>
References: <1367936303-13386-1-git-send-email-jslaby@suse.cz>
 <1367936303-13386-15-git-send-email-jslaby@suse.cz>
 <20130507192938.GA3599@netboy> <51924819.3060907@suse.cz>
 <20130514181234.GH31561@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Richard Cochran <richardcochran@gmail.com>,
	Jiri Slaby <jirislaby@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Jeff Mahoney <jeffm@suse.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>, Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130514181234.GH31561@decadent.org.uk>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Ben Hutchings
> Sent: Tuesday, May 14, 2013 11:13 AM
> To: Jiri Slaby
> Cc: Richard Cochran; Jiri Slaby; linux-kernel@vger.kernel.org; Jeff
> Mahoney; netdev@vger.kernel.org
> Subject: Re: [PATCH 15/15] ptp: PTP_1588_CLOCK_PCH depends on x86
> 
> On Tue, May 14, 2013 at 04:20:09PM +0200, Jiri Slaby wrote:
> > On 05/07/2013 09:29 PM, Richard Cochran wrote:
> > > On Tue, May 07, 2013 at 04:18:23PM +0200, Jiri Slaby wrote:
> > >> From: Jeff Mahoney <jeffm@suse.com>
> > >>
> > >> The PCH EG20T is only compatible with Intel Atom processors so it
> > >> should depend on x86.
> > >
> > > This patch has been submitted before,
> > >
> > >    https://patchwork.kernel.org/patch/2069071/
> > >
> > > and at that time the reaction was that it is good to have drivers
> > > cross-compiled, if only for code quality reasons.
> >
> > Hmm, then it depends whether the kernel is for users or for
> developers.
> > I, as a user, do not really want to compile drivers with allmodconfig
> > which I have no way to load/use.
> >
> > And allmodconfig is basically what we, users (SUSE distributors in this
> > case) do. So having this driver being built makes our life harder (in
> > the meaning we have to have specific rules about disabling unwanted
> > drivers from configs).
> 
> Wearing my Debian hat, I agree with this.  Perhaps we could define a
> CONFIG_BUILD_TEST symbol for people who want to do that, and then
> make drivers for hardware that's only found in x86 systems (for
> example) depend on X86 || BUILD_TEST.
> 
> Ben.
> 

I agree with this.

- Jake Keller

> > And, developers should have a testbed where they build 32bit configs.
> > And we actually have that for -next AFAIU.
> > --
> Ben Hutchings
> We get into the habit of living before acquiring the habit of thinking.
>                                                               - Albert Camus
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
