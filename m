From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH v3 2/4] kconfig: regenerate *.c_shipped files after
 previous changes
Date: Mon, 7 Nov 2016 15:12:36 -0800
Message-ID: <20161107231236.c7p7fqefckwxcsvv@jtriplet-mobl2.jf.intel.com>
References: <1478556899-2951-1-git-send-email-nicolas.pitre@linaro.org>
 <1478556899-2951-3-git-send-email-nicolas.pitre@linaro.org>
 <20161107223149.pgs5dqtbw5aprow7@jtriplet-mobl2.jf.intel.com>
 <alpine.LFD.2.20.1611071733010.14694@knanqh.ubzr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Stultz <john.stultz@linaro.org>,
        Michal Marek <mmarek@suse.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Paul Bolle <pebolle@tiscali.nl>,
        Thomas Gleixner <tglx@linutronix.de>,
        Edward Cree <ecree@solarflare.com>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Return-path: <linux-kbuild-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.20.1611071733010.14694@knanqh.ubzr>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 07, 2016 at 05:41:38PM -0500, Nicolas Pitre wrote:
> On Mon, 7 Nov 2016, Josh Triplett wrote:
> 
> > [snipping large patch]
> > 
> > One suggestion that might make this patch easier to review: you might
> > consider first regenerating the unchanged parser with Bison 3.0.4, then
> > regenerating it again after the "imply" change.  I think that'd
> > eliminate quite a lot of noise in this patch.
> 
> I tried that. This made two large patches instead of just one, both 
> equally obscure.
> 
> So this patch stands on its own, containing changes that are 
> mechanically generated and therefore shouldn't require manual review.

Fair enough. I hadn't expected that the changes from "imply" would still
be huge.
