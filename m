From: Dave Dillow <dave@thedillows.org>
Subject: Re: [RFC 2.6.10 1/22] xfrm: Add direction information to xfrm_state
Date: Thu, 30 Dec 2004 11:16:49 -0500
Message-ID: <1104423409.23254.9.camel@dillow.idleaire.com>
References: <20041230035000.01@ori.thedillows.org>
	 <20041230035000.10@ori.thedillows.org>  <20041230094839.GX2460@lug-owl.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261655AbUL3QQ5@vger.kernel.org>
To: Jan-Benedict Glaw <jbglaw@lug-owl.de>
In-Reply-To: <20041230094839.GX2460@lug-owl.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2004-12-30 at 04:48, Jan-Benedict Glaw wrote:
> On Thu, 2004-12-30 03:48:34 -0500, David Dillow <dave@thedillows.org>
> wrote in message <20041230035000.10@ori.thedillows.org>:
> > diff -Nru a/include/net/xfrm.h b/include/net/xfrm.h
> > --- a/include/net/xfrm.h	2004-12-30 01:12:08 -05:00
> > +++ b/include/net/xfrm.h	2004-12-30 01:12:08 -05:00
> > @@ -146,6 +146,9 @@
> >  	/* Private data of this transformer, format is opaque,
> >  	 * interpreted by xfrm_type methods. */
> >  	void			*data;
> > +
> > +	/* Intended direction of this state, used for offloading */
> > +	int			dir;
> >  };
> >  
> >  enum {
> > @@ -157,6 +160,12 @@
> >  	XFRM_STATE_DEAD
> >  };
> >  
> > +enum {
> > +	XFRM_STATE_DIR_UNKNOWN,
> > +	XFRM_STATE_DIR_IN,
> > +	XFRM_STATE_DIR_OUT,
> > +};
> 
> Any specific reason to first define such a nice enum and then using int
> in the struct?

Just following the current style in net/xfrm.h, see xfrm_state.km.state
and XFRM_STATE_*.

Though, I probably should have used a u8; easily changed if it is an
issue.
-- 
Dave Dillow <dave@thedillows.org>
