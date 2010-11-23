From: Ward Vandewege <ward@gnu.org>
Subject: Re: pc300too on a modern kernel?
Date: Tue, 23 Nov 2010 09:44:28 -0500
Message-ID: <20101123144428.GA18504@countzero.vandewege.net>
References: <20100902131531.GA19028@countzero.vandewege.net>
 <m3mxrw1lg0.fsf@intrepid.localdomain>
 <1289421869.9336.49.camel@giskard.codewiz.org>
 <m3sjz34mka.fsf@intrepid.localdomain>
 <1289944619.2677.22.camel@giskard.codewiz.org>
 <m3tyjd7za9.fsf@intrepid.localdomain>
 <1290442675.5515.92.camel@giskard.codewiz.org>
 <m38w0l2gzh.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bernie Innocenti <bernie@codewiz.org>,
	lkml <linux-kernel@vger.kernel.org>,
	Jan Seiffert <kaffeemonster@googlemail.com>,
	netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m38w0l2gzh.fsf@intrepid.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 22, 2010 at 10:20:02PM +0100, Krzysztof Halasa wrote:
> > With this workaround applied, we're st seeing occasional clusters of
> > packet loss. We're working to graph the ping loss alongside traffic to
> > see if there's any correlation.
> 
> That's interesting. I remember seeing some TX underruns at higher
> speeds, though nothing alike at 2 Mb/s. What bit rate are you using?
> Does "ifconfig hdlc0" show any errors?

This turned out to be caused by line saturation. We were not seeing this
before we upgraded to the latest kernel because we have a set of qos rules
that we forgot to install on our new box. Mea culpa...

Thanks,
Ward.

-- 
Ward Vandewege <ward@gnu.org>
