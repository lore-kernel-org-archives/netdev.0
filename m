From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH v2 1/5] kconfig: introduce the "imply" keyword
Date: Fri, 28 Oct 2016 18:03:15 -0400 (EDT)
Message-ID: <alpine.LFD.2.20.1610281802220.14694@knanqh.ubzr>
References: <1477448931-29051-1-git-send-email-nicolas.pitre@linaro.org> <1477448931-29051-2-git-send-email-nicolas.pitre@linaro.org> <1477613871.2121.92.camel@tiscali.nl> <alpine.LFD.2.20.1610272156050.14694@knanqh.ubzr>
 <1477690300.2167.26.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: John Stultz <john.stultz@linaro.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Michal Marek <mmarek@suse.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>,
        Edward Cree <ecree@solarflare.com>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477690300.2167.26.camel@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Oct 2016, Paul Bolle wrote:

> On Thu, 2016-10-27 at 23:10 -0400, Nicolas Pitre wrote:
> > On Fri, 28 Oct 2016, Paul Bolle wrote:
> > > What happens when a tristate symbol is implied by a symbol set to 'y'
> > > and by a symbol set to 'm'?
> > 
> > That's respectively the third and second rows in the table above.
> 
> I meant: two separate symbols implying the same symbol at the same
> time. One of those symbols set to 'y' and the other set to 'm'.

Then it's the greatest of the set i.e. y.


Nicolas
