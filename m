From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH v2 1/5] kconfig: introduce the "imply" keyword
Date: Fri, 28 Oct 2016 23:26:52 +0200
Message-ID: <1477690012.2167.21.camel@tiscali.nl>
References: <1477448931-29051-1-git-send-email-nicolas.pitre@linaro.org>
         <1477448931-29051-2-git-send-email-nicolas.pitre@linaro.org>
         <1477613871.2121.92.camel@tiscali.nl>
         <alpine.LFD.2.20.1610272156050.14694@knanqh.ubzr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: John Stultz <john.stultz@linaro.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Michal Marek <mmarek@suse.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>,
        Edward Cree <ecree@solarflare.com>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.20.1610272156050.14694@knanqh.ubzr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-10-27 at 23:10 -0400, Nicolas Pitre wrote:
> On Fri, 28 Oct 2016, Paul Bolle wrote:
> > You probably got "["if" <expr>]" for free by copying what's there for
> > select. But this series doesn't use it, so perhaps it would be better
> > to not document it yet. But that is rather sneaky. Dunno.
> 
> If it is not documented then the chance that someone uses it are slim. 
> And since it comes "for free" I don't see the point of making the tool 
> less flexible. And not having this flexibility could make some 
> transitions from "select" to "imply" needlessly difficult.

My point is moot. I somehow missed that this series adds
    imply PTP_1588_CLOCK if TILEGX

So you are quite right in documenting this.


Paul Bolle
