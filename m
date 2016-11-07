From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH v3 2/4] kconfig: regenerate *.c_shipped files after
 previous changes
Date: Mon, 7 Nov 2016 17:41:38 -0500 (EST)
Message-ID: <alpine.LFD.2.20.1611071733010.14694@knanqh.ubzr>
References: <1478556899-2951-1-git-send-email-nicolas.pitre@linaro.org> <1478556899-2951-3-git-send-email-nicolas.pitre@linaro.org> <20161107223149.pgs5dqtbw5aprow7@jtriplet-mobl2.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: John Stultz <john.stultz@linaro.org>,
        Michal Marek <mmarek@suse.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Paul Bolle <pebolle@tiscali.nl>,
        Thomas Gleixner <tglx@linutronix.de>,
        Edward Cree <ecree@solarflare.com>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: Josh Triplett <josh@joshtriplett.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161107223149.pgs5dqtbw5aprow7@jtriplet-mobl2.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 7 Nov 2016, Josh Triplett wrote:

> [snipping large patch]
> 
> One suggestion that might make this patch easier to review: you might
> consider first regenerating the unchanged parser with Bison 3.0.4, then
> regenerating it again after the "imply" change.  I think that'd
> eliminate quite a lot of noise in this patch.

I tried that. This made two large patches instead of just one, both 
equally obscure.

So this patch stands on its own, containing changes that are 
mechanically generated and therefore shouldn't require manual review.


Nicolas
