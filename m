From: David Gibson <hermes@gibson.dropbear.id.au>
Subject: Re: [PATCH 2.6.10-rc1 3/15] wireless/orinoco: encapsulate direct hardware operations
Date: Wed, 27 Oct 2004 13:15:16 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027031516.GH7925@zax>
References: <1098814320.3663.24.camel@dcbw.boston.redhat.com> <1098816189.3663.47.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dan Williams <dcbw@redhat.com>
Content-Disposition: inline
In-Reply-To: <1098816189.3663.47.camel@dcbw.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 26, 2004 at 02:43:09PM -0400, Dan Williams wrote:
> Update in-kernel orinoco wireless drivers to upstream CVS.
> None of this is original code by Dan Williams, simply a
> broken down patch set split-out from upstream orinoco CVS.
> 
> o Encapsulate direct hardware operations so those symbols
>     don't need to be exported

No!  Don't apply this.  This abstraction is only needed for the
orinoco_usb driver (so is in HEAD, but not the for_linus branch), but
IMO the abstraction is in the wrong place, and should not go
upstream.  Of course, patches to make the abstraction not suck are
welcome.

-- 
David Gibson			| For every complex problem there is a
david AT gibson.dropbear.id.au	| solution which is simple, neat and
				| wrong.
http://www.ozlabs.org/people/dgibson
