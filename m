From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH v3 8/7] pppoatm: fix missing wakeup in pppoatm_send()
Date: Tue, 27 Nov 2012 10:23:33 -0500
Message-ID: <20121127102333.68ac3234@thirdoffive.cmf.nrl.navy.mil>
References: <201211112257.qABMvhP4021769@thirdoffive.cmf.nrl.navy.mil>
	<1354022867.26346.334.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Mazur <krzysiek@podlesie.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1354022867.26346.334.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Nov 2012 13:27:47 +0000
David Woodhouse <dwmw2@infradead.org> wrote:

> > i really would prefer not to use a strange name since it might confuse
> > larger group of people who are more familiar with the traditional meaning
> > of this function.  vcc_release() isnt exported so we could rename it if
> > things get too confusing.
> > 
> > i have to look at this a bit more but we might be able to use release_cb
> > to get rid of the null push to detach the underlying protocol.  that would
> > be somewhat nice.
> 
> In the meantime, should I resend this patch with the name 'release_cb'
> instead of 'unlock_cb'? I'll just put a comment in to make sure it isn't
> confused with vcc_release(), and if we need to change vcc_release()
> later we can.
> 

yes, but dont call it 8/7 since that doesnt make sense.
