From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: iproute2 regression -- ss -u returns an empty list
Date: Tue, 28 Apr 2015 07:47:08 +0300
Message-ID: <20150428044708.GA22671@angus-think.lan>
References: <553EE0D9.3050601@ionic.de>
 <20150428040516.GA14129@angus-think.lan>
 <553F0D8E.9060602@ionic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Mihai Moldovan <ionic@ionic.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:36473 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932356AbbD1Er2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 00:47:28 -0400
Received: by lagv1 with SMTP id v1so95434205lag.3
        for <netdev@vger.kernel.org>; Mon, 27 Apr 2015 21:47:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <553F0D8E.9060602@ionic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 28, 2015 at 06:33:18AM +0200, Mihai Moldovan wrote:
> On 28.04.2015 06:05 AM, Vadim Kochan wrote:> So by default ss prints socket with
> CONNECTED state and even UDP can be
> > in the CONNECTED state on the Linux,
> 
> UDP can be in a CONNECTED state... ooookay. That's probably a conntrack thing.
> 
> 
> > so you can specify 'ss -ua' (may be
> > some explanation should be added to the ss man page) which
> > should print UDP sockets in the any state, AFAIK it was the default
> > behaviour before my changes.
> 
> Could this please be reverted? It's breaking other stuff that uses ss.
> 
> Also: ss -lxua returns an empty list, too. Previously, the families seem to have
> been OR'd, while they are now ANDed?
> 
> 
> 
> Mihai
> 

I will try to fix this ...
