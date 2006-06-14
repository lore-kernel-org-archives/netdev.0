From: "Brian F. G. Bidulock" <bidulock@openss7.org>
Subject: Re: [RFC/PATCH 1/2] in-kernel sockets API
Date: Wed, 14 Jun 2006 00:07:10 -0600
Message-ID: <20060614000710.C7232@openss7.org>
References: <1150156562.19929.32.camel@w-sridhar2.beaverton.ibm.com> <200606131859.43695.chase.venters@clientec.com> <20060613183112.B8460@openss7.org> <200606131953.42002.chase.venters@clientec.com>
Reply-To: bidulock@openss7.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.openss7.com ([142.179.199.224]:4022 "EHLO gw.openss7.com")
	by vger.kernel.org with ESMTP id S932405AbWFNGHN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2006 02:07:13 -0400
To: Chase Venters <chase.venters@clientec.com>
Content-Disposition: inline
In-Reply-To: <200606131953.42002.chase.venters@clientec.com>; from chase.venters@clientec.com on Tue, Jun 13, 2006 at 07:53:19PM -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chase,

On Tue, 13 Jun 2006, Chase Venters wrote:
> 
> > I don't think that it is fair to say that an unstable API/ABI, in of
> > itself, provides an incentive to open an existing proprietary driver.
> 
> Sure it does, depending on your perspective and what you're willing to 
> consider. The lack of a stable API/ABI means that if you don't want to have 
> to do work tracking the kernel, you should push to have your drivers merged.
> 

More work must be done to track the kernel before they are merged, thus
purposeless API changes, or unnecessary use of EXPORT_SYMBOL_GPL impedes
merging

Not all useful kernel modules will nor should be merged GPL or not.

I think that a policy that intentionally makes it hard for proprietary
modules to be developed defeats the purpose of ultimate opening and merging.
It might end up causing something like iBCS, LinuxABI, SVR D3DK, or ODI to
flourish obviating the principal goal.

The interface currently under discussion is ultimately derived from the BSD
socket-protocol interface, and IMHO should be EXPORT_SYMBOL instead of
EXPORT_SYMBOL_GPL, if only because using _GPL serves no purpose here and can
be defeated with 3 or 4 obvious (and probably existing) lines of code.  I
wrote similar wrappers for STREAMS TPI to Linux NET4 interface instead of
using pointers directly quite a few years ago.  I doubt I was the first.
There is nothing really so novel here that it deserves _GPL.

