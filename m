From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: [PATCH][ATM]: [ioctl][1/8] move vcc_ioctl() to ioctl.c (from levon@movementarian.org)
Date: Thu, 25 Sep 2003 12:41:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030925194103.GE31418@gaz.sfgoth.com>
References: <20030925170342.GA74937@compsoc.man.ac.uk> <200309251928.h8PJSZkT011995@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Levon <levon@movementarian.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas williams <chas@cmf.nrl.navy.mil>
Content-Disposition: inline
In-Reply-To: <200309251928.h8PJSZkT011995@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

chas williams wrote:
> i redid your patch set a bit to just get from point a to b w/o
> the phantom ioctl.h and with the ATM_VF_IS_CLIP change discussed earlier.

If you merge my patches the vcc->clip would go away on its own (its not needed
once CLIP gets a atm_backend->decribe_vcc() method)

-Mitch
