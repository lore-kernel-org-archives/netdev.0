From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][ATM][2.4] export try_atm_clip_ops not
 atm_clip_ops_mutex
Date: Wed, 30 Jul 2003 15:58:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030730155844.43ca22d9.davem@redhat.com>
References: <20030730102437.B3901@infradead.org>
	<200307301435.h6UEZDsG010062@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, hch@infradead.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas3@users.sourceforge.net
In-Reply-To: <200307301435.h6UEZDsG010062@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 30 Jul 2003 10:32:31 -0400
chas williams <chas@cmf.nrl.navy.mil> wrote:

> In message <20030730102437.B3901@infradead.org>,Christoph Hellwig writes:
> >On Tue, Jul 29, 2003 at 10:33:27PM -0700, David S. Miller wrote:
> >Hmm, this looks like a fix for modular compilation and should
> >probably go into 2.4.22..
> 
> i would prefer it to be applied to 2.4.22 but if it cant be done
> it cant be done.  i am not pressed.

Modular ATM is a new attribute of 2.4.22, so if it is broken in
some way we are no worse off than we were in 2.4.21

I really don't consider this critical at all.  And itsy bitsy fixes
like this continually pouring into Marcelo's tree in late stages are
why his releases get delayed for so long, and I'm not going to
contribute to that problem.
