From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 02/14] atm/nicstar: don't use idr_remove_all()
Date: Mon, 4 Feb 2013 10:35:08 -0800
Message-ID: <20130204183508.GU27963@mtj.dyndns.org>
References: <1359163872-1949-1-git-send-email-tj@kernel.org>
 <1359163872-1949-3-git-send-email-tj@kernel.org>
 <20130204175210.GQ27963@mtj.dyndns.org>
 <20130204131034.5bea17c4@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, rusty@rustcorp.com.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130204131034.5bea17c4@thirdoffive.cmf.nrl.navy.mil>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey,

On Mon, Feb 04, 2013 at 01:10:34PM -0500, chas williams - CONTRACTOR wrote:
> you assign id1 to 0, so this never happens i think.  i don't think the
> reason to preassign id1/id2 exists anymore once the do loop is removed.
> 
> > +			id1 = idr_alloc(&card->idr, handle1, 0, 0, GFP_ATOMIC);
> > +			if (id1 < 0) {
> > +				err = id1;
> 
> you dont need to assign err since it isn't returned.

Heh, I put v2 under the wrong thread.  I'll do v3 and post it under
v1.

Thanks.

-- 
tejun
