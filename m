From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: WARNING: at net/ipv4/tcp_input.c
Date: Thu, 29 May 2008 11:10:39 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805291049420.19431@wrl-59.cs.helsinki.fi>
References: <4815BCDF.6070704@andyfurniss.entadsl.com>
 <Pine.LNX.4.64.0804281714090.1888@wrl-59.cs.helsinki.fi>
 <48162070.4030405@andyfurniss.entadsl.com> <Pine.LNX.4.64.0804282210390.16635@wrl-59.cs.helsinki.fi>
 <481986FD.8070108@andyfurniss.entadsl.com> <Pine.LNX.4.64.0805011216230.19286@wrl-59.cs.helsinki.fi>
 <48199342.9010406@andyfurniss.entadsl.com> <Pine.LNX.4.64.0805021342480.30402@wrl-59.cs.helsinki.fi>
 <481C54AF.1050109@andyfurniss.entadsl.com> <Pine.LNX.4.64.0805121349400.1888@wrl-59.cs.helsinki.fi>
 <483E0848.6030307@andyfurniss.entadsl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Andy Furniss <lists@andyfurniss.entadsl.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56659 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565AbYE2IKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2008 04:10:43 -0400
In-Reply-To: <483E0848.6030307@andyfurniss.entadsl.com>
Content-ID: <Pine.LNX.4.64.0805291049422.19431@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 May 2008, Andy Furniss wrote:

> ? wrote:
> > On Sat, 3 May 2008, Andy Furniss wrote:
> > 
> > > Ilpo J?rvinen wrote:
> > >
> > > > Since I've not yet found any other path that could lead to it except the
> > > > yesterday's false-positive, getting the write queue state more
> > > > accurately
> > > > captured by the debug patch on the very first occassion might help.
> > > > Here's
> > > > less spammy version of the debug patch (I added one printout as well to
> > > > get
> > > > more usefulness to transitional state reported).
> > > >
> > > OK, increased CONFIG_LOG_BUF_SHIFT from 14 to 18 and reversed old /
> > > applied
> > > new patch.
> > 
> > Any luck so far?
> > 
> 
> Finally - looks like I got two together.
> 
> It doesn't start with WARNING - but dmesg isn't full.

This looks ok trace this time :-), I changed the ordering of the lines so 
that warning was supposed to appear only after the wq print. Now it's just 
the hard par remaining, ie., I must figure out what was the state of TCP 
before the event the event... :-).

If you still get additional events (you could if a particular torrent 
peer is there having the same network behavior), please post them as well 
if they reveal something that helps exclude cases (if I don't right away 
get the idea :-)).

-- 
 i.
