From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH v3 8/7] pppoatm: fix missing wakeup in pppoatm_send()
Date: Sun, 11 Nov 2012 17:57:43 -0500
Message-ID: <201211112257.qABMvhP4021769@thirdoffive.cmf.nrl.navy.mil>
References: <1352667081.9449.135.camel@shinybook.infradead.org>
Cc: Krzysztof Mazur <krzysiek@podlesie.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1352667081.9449.135.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In message <1352667081.9449.135.camel@shinybook.infradead.org>,David Woodhouse writes:
>Acked-by: David Woodhouse <David.Woodhouse@intel.com> for your new
>version of patch #6 (returning DROP_PACKET for !VF_READY), and your
>followup to my patch #8, adding the 'need_wakeup' flag. Which we might
>as well merge into (the pppoatm part of) my patch.
>
>Chas, are you happy with the generic ATM part of that? And the
>nomenclature? I didn't want to call it 'release_cb' like the core socket
>code does, because we use 'release' to mean something different in ATM.
>So I called it 'unlock_cb' instead...

i really would prefer not to use a strange name since it might confuse
larger group of people who are more familiar with the traditional meaning
of this function.  vcc_release() isnt exported so we could rename it if
things get too confusing.

i have to look at this a bit more but we might be able to use release_cb
to get rid of the null push to detach the underlying protocol.  that would
be somewhat nice.
