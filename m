From: Robert MARKLUND <robert.marklund@stericsson.com>
Subject: RE: [PATCH] smsc911x: Add regulator support
Date: Mon, 17 Oct 2011 16:13:47 +0200
Message-ID: <2B1D156D95AE9B4EAD379CB9E465FE7324AB09E052@EXDCVYMBSTM005.EQ1STM.local>
References: <1318834597-3479-1-git-send-email-robert.marklund@stericsson.com>
 <20111017105256.GG5448@sirena.org.uk>
 <2B1D156D95AE9B4EAD379CB9E465FE7324AB09DE76@EXDCVYMBSTM005.EQ1STM.local>
 <20111017123614.GC27266@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Mathieu Poirer <mathieu.poirier@linaro.org>
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:49198 "EHLO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751167Ab1JQON7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Oct 2011 10:13:59 -0400
In-Reply-To: <20111017123614.GC27266@opensource.wolfsonmicro.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Mark Brown [mailto:broonie@opensource.wolfsonmicro.com]
> Sent: den 17 oktober 2011 14:36
> To: Robert MARKLUND
> Cc: netdev@vger.kernel.org; Steve Glendinning; Mathieu Poirer
> Subject: Re: [PATCH] smsc911x: Add regulator support
> 
> On Mon, Oct 17, 2011 at 01:30:06PM +0200, Robert MARKLUND wrote:
> 
> You should fix your mail client to word wrap within paragraphs, I've
> reformatted it for legibility.  Also leave a blank line between
> paragraphs for the same reason.

I have tried but it's not as easy as it sounds :)
Does it look better now ?

> 
> > > No, this is broken - look at how other devices use the regulator API.
> > > The driver should just request and use the regulators unconditionally
> > > and let the stubbing and mapping facilities the API has deal with
> > > ensuring that they always succeed.
> 
> > So what you mean is get them and use them and ignore all the return
> > codes, and let the FW take care of the error handling ?
> 
> No, you should do what all the other drivers do and actually pay
> attention to the errors.  If we can't get power to the device that's a
> pretty serious problem and the driver ought  to fail.

Then I don't understand the initial comment.
Can you please elaborate that one.

> 
> > > As a side note the use of "pdata" as a name for the driver internal data
> > > is really not helpful, pdata is traditionally the platform data passed
> > > in by the machine (which would be even more broken).
> 
> > In the driver they have used this name for this structure throughout
> > the file I just followed that.  Personally I think it will be more
> > confusing to change the name of this structure in just this new
> > function.
> 
> I think someone should send a patch renaming the data throughout the
> entire driver, it's a terrible name for an embedded context.

I agree let this someone do it.
In the meanwhile isn't it best to keep the style that in the driver as of now.

/R
