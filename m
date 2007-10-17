From: jamal <hadi@cyberus.ca>
Subject: Re: Difference between device statistics from ifconfig and ip -s l
	l
Date: Wed, 17 Oct 2007 08:01:38 -0400
Message-ID: <1192622498.4460.25.camel@localhost>
References: <20071017092659.GA16356@wq.cz> <4715D79E.7020201@trash.net>
	 <20071017101303.GB16356@wq.cz> <4715E57F.6080905@trash.net>
	 <20071017112919.GC16356@wq.cz>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Milan Kocian <milon@wq.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:31691 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753874AbXJQMCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 08:02:13 -0400
Received: by wa-out-1112.google.com with SMTP id v27so2753500wah
        for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 05:02:12 -0700 (PDT)
In-Reply-To: <20071017112919.GC16356@wq.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-17-10 at 13:29 +0200, Milan Kocian wrote:
> On Wed, Oct 17, 2007 at 12:35:43PM +0200, Patrick McHardy wrote:
> > Milan Kocian wrote:
> >> On Wed, Oct 17, 2007 at 11:36:30AM +0200, Patrick McHardy wrote:
> >>
> >>> ifconfig gets its data from /proc/net/dev, which adds up rx_errors
> >>> and rx_missed.
> >>>
> >> Adds up rx_errors and rx_missed and prints it as dropped ? Ok, ifconfig is
> >> a little old. But why I don't see missed packets from RX errors detailed 
> >> stats (ip -s -s l l) in non-detailed stats as errors and see zero ?
> >
> >
> > I meant to write "adds up rx_dropped and rx_missed".
> 
> ok.
> 
> One probably stupid question: Why is not done similar sum in output of 'ip -s l l' ?

"missed" is not really an error. It just means the driver was
overwhelmed and didnt even get the chance of seeing it whereas an error
is something the driver processed and saw a problem with it.

> Imagine me :), I do 'ifconfig' and see dropped packets and then I do 'ip -s l l'
> and see zeros. I stare on it like an idiot. Where is bug ? ifconfig ? ip ?
> (man page of ip and 'ip -s -s l l' with missed packets stats saved me :).
> 
> IMHO I think that comparable outputs of both programs should be still the same.

I think ifconfig sums them up so the output formatting looks nice, but
ip is more accurate. These stats are from standard SNMP mibs (off top of
my head RFC1213 if it hasnt been obsoleted by something) - look at
InIFxxxx stats.

cheers,
jamal


