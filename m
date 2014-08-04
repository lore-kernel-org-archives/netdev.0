From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless-next 2014-08-01
Date: Mon, 4 Aug 2014 10:53:43 -0400
Message-ID: <20140804145342.GB16658@tuxdriver.com>
References: <20140801165738.GA26953@tuxdriver.com>
 <20140802.193939.2179004210212543536.davem@davemloft.net>
 <C2EB98EF-6873-4F44-B914-A9F89146914A@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	"linux-wireless@vger.kernel.org Wireless"
	<linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <C2EB98EF-6873-4F44-B914-A9F89146914A@holtmann.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 03, 2014 at 10:37:16AM -0700, Marcel Holtmann wrote:
> Hi Dave,
> 
> >> Please pull this last(?) batch of wireless change intended for the
> >> 3.17 stream...
> > 
> > When I pull this I get tons of conflicts for:
> > 
> > CONFLICT (content): Merge conflict in net/6lowpan/iphc.c
> > 
> > I don't feel comfortable fixing these up, where are they coming
> > from?
> 
> I was short on time yesterday, but now I checked up on this in detail. The merge conflicts are actually simple to resolve. You can just rely on John's tree to have the more recent net/6lowpan/ tree. I should have insisted on merging net/6lowpan/ through bluetooth-next and wireless-next way earlier to avoid conflicts.
> 
> In the future we will avoid this by ensuring that all goes via bluetooth-next first. Sorry for this confusion. John mentioned these merge conflicts in his footnote.
> 
> John, do you just want to resolve the merge conflicts and send Dave a new pull request?

I'm happy to do that, if Dave wants.  But as you say, once the initial
shock of all those conflicts passes the resolution really is fairly
simple. :-)

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
