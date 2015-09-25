From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: 4.1.0, kernel panic, pppoe_release
Date: Fri, 25 Sep 2015 21:02:49 +0200
Message-ID: <20150925190249.GA2962@alphalink.fr>
References: <677da51dbac367fcb7a456de2789334b@visp.net.lb>
 <c6e2cb4002bf11ad7a25be8eeded2dc1@visp.net.lb>
 <1437147400.5437.4.camel@redhat.com>
 <de4b28603ef7bcaea7aeca73dab80079@visp.net.lb>
 <20150910155657.GC3661@alphalink.fr>
 <9392178bf13d2814e19b1756cd204d73@visp.net.lb>
 <20150925143831.GI2869@alphalink.fr>
 <3e1192bd3125fd5054c1417bce869505@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>, Netdev <netdev@vger.kernel.org>,
	ebiederm@xmission.com, davem@davemloft.net, simon@farnz.org.uk,
	develop@kristov.de
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:38563 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932786AbbIYTC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 15:02:56 -0400
Content-Disposition: inline
In-Reply-To: <3e1192bd3125fd5054c1417bce869505@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 25, 2015 at 06:02:42PM +0300, Denys Fedoryshchenko wrote:
> On 2015-09-25 17:38, Guillaume Nault wrote:
> >On Tue, Sep 22, 2015 at 04:47:48AM +0300, Denys Fedoryshchenko wrote:
> >>Hi,
> >>Sorry for late reply, was not able to push new kernel on pppoes without
> >>permissions (it's production servers), just got OK.
> >>
> >>I am testing patch on another pppoe server with 9k users, for ~3 days,
> >>seems
> >>fine. I will test today
> >>also on server that was experiencing crashes within 1 day.
> >>
> >Thanks for the feedback. I'm about to submit a fix. Should I add a
> >Tested-by tag for you?
> On one of servers i got same crash as before, within hours. 9k users server
> also crashed after while, so it seems it doesn't help.
> I will do some more tests tomorrow.
Ok, this must be a different bug then. Do you have a trace of a crash
with the patched kernel?
