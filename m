From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Preferred method for configuration
Date: Thu, 8 Aug 2013 09:01:11 -0700
Message-ID: <20130808090111.241a2043@nehalam.linuxnetplumber.net>
References: <52032D5E.6070307@hhi.fraunhofer.de>
	<1375940480.2424.135.camel@joe-AO722>
	<520332F4.5020206@hhi.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Thomas Martitz <thomas.martitz@hhi.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:50057 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757733Ab3HHQBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 12:01:16 -0400
Received: by mail-pb0-f47.google.com with SMTP id rr4so3404881pbb.20
        for <netdev@vger.kernel.org>; Thu, 08 Aug 2013 09:01:16 -0700 (PDT)
In-Reply-To: <520332F4.5020206@hhi.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 08 Aug 2013 07:56:04 +0200
Thomas Martitz <thomas.martitz@hhi.fraunhofer.de> wrote:

> Resent with list in CC.
> 
> Am 08.08.2013 07:41, schrieb Joe Perches:
> > On Thu, 2013-08-08 at 07:32 +0200, Thomas Martitz wrote:
> >> Hello,
> >>
> >> I'm developing a NIC driver and currently export some custom
> >> configuration settings and actions (e.g. enabling a loopback mode) via
> >> sysfs.
> >
> > Is there some reason you don't want to use ethtool?
> >
> >
> 
> It doesn't allow for custom settings does it? For standards stuff I'm 
> sure going to use ethtool.

Any feature "special to my driver" is sure to meet stiff resistance
from the kernel developers. Special features make it impossible for generic
configuration in distributions and by management layers.
