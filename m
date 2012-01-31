From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: Re: [PATCH 01/16] eicon: fix -Warray-bounds warning
Date: Tue, 31 Jan 2012 18:04:19 +0100
Message-ID: <201201311804.20464.danny.kukawka@bisect.de>
References: <1327960820-11867-1-git-send-email-danny.kukawka@bisect.de> <1327964972.2595.31.camel@bwh-desktop> <20120131152534.GA14825@gw.linux-pingi.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Armin Schindler <mac@melware.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>
To: Karsten Keil <kkeil@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120131152534.GA14825@gw.linux-pingi.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Dienstag, 31. Januar 2012, Karsten Keil wrote:
> On Mon, Jan 30, 2012 at 11:09:32PM +0000, Ben Hutchings wrote:
> > On Mon, 2012-01-30 at 23:00 +0100, Danny Kukawka wrote:
> > > Fix for a -Warray-bounds warning. mixer_notify_update() tries to
> > > write to ((CAPI_MSG *) msg)->info.facility_req.structs[3] while
> > > structs is defined as byte structs[1], define structs[1] as
> > > structs[4].
> >
> > I suspect that all the 'byte structs[1];' fields defined in that header
> > are actually variable-length arrays.  In that case, there may be no
> > reasonable bound you can specify.
>
> Yes, exactely, the structs is a ASN1 coded message so it can have any len.

So, how can we get rid of the compiler warning then?

Danny

> Karsten
