From: Robert MARKLUND <robert.marklund@stericsson.com>
Subject: RE: [PATCH] smsc911x: Add regulator support
Date: Mon, 17 Oct 2011 17:28:08 +0200
Message-ID: <2B1D156D95AE9B4EAD379CB9E465FE7324AB09E0EE@EXDCVYMBSTM005.EQ1STM.local>
References: <1318834597-3479-1-git-send-email-robert.marklund@stericsson.com>
 <20111017105256.GG5448@sirena.org.uk>
 <2B1D156D95AE9B4EAD379CB9E465FE7324AB09DE76@EXDCVYMBSTM005.EQ1STM.local>
 <20111017123614.GC27266@opensource.wolfsonmicro.com>
 <2B1D156D95AE9B4EAD379CB9E465FE7324AB09E052@EXDCVYMBSTM005.EQ1STM.local>
 <20111017143358.GI5448@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Mathieu Poirer <mathieu.poirier@linaro.org>
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:55505 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751171Ab1JQP2S convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Oct 2011 11:28:18 -0400
In-Reply-To: <20111017143358.GI5448@sirena.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Mark Brown [mailto:broonie@opensource.wolfsonmicro.com]
> Sent: den 17 oktober 2011 16:34
> To: Robert MARKLUND
> Cc: netdev@vger.kernel.org; Steve Glendinning; Mathieu Poirer
> Subject: Re: [PATCH] smsc911x: Add regulator support
> 
> On Mon, Oct 17, 2011 at 04:13:47PM +0200, Robert MARKLUND wrote:
> 
> > > You should fix your mail client to word wrap within paragraphs, I've
> > > reformatted it for legibility.  Also leave a blank line between
> > > paragraphs for the same reason.
> 
> > I have tried but it's not as easy as it sounds :)
> > Does it look better now ?
> 
> Yes, thanks.
> 
> > > No, you should do what all the other drivers do and actually pay
> > > attention to the errors.  If we can't get power to the device that's a
> > > pretty serious problem and the driver ought  to fail.
> 
> > Then I don't understand the initial comment.
> > Can you please elaborate that one.
> 
> If we fail to grab a critical resource for the device like the power
> supply then we should be failing passing the error back.  As I keep
> saying this is what all the other regulator consumers are doing.

Most of the boards out there don't have any regulators for the chip(power is always on).
So when we can't get the regulator, we assume that the power is already on.
That's why it hasn't been implemented before.

So adding this functionality will make all the other boards out there fail, to start the driver.

/R
