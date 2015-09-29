From: Peter =?UTF-8?B?TsO4cmx1bmQ=?= <pch@ordbogen.com>
Subject: Re: Per-flow IPv4 ECMP
Date: Tue, 29 Sep 2015 14:35:32 +0200
Message-ID: <20150929143532.7242b0ca@pch.odense.ordbogen.com>
References: <BN1PR0201MB05777291EE3D91068CB2EE8E944F0@BN1PR0201MB0577.namprd02.prod.outlook.com>
	<56094519.8030801@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matthew Dupre <Matthew.Dupre@metaswitch.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ordbogen.com ([91.240.88.21]:54867 "EHLO mail.ordbogen.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756058AbbI2Mfe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 08:35:34 -0400
In-Reply-To: <56094519.8030801@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Sep 2015 06:48:09 -0700
roopa <roopa@cumulusnetworks.com> wrote:

> On 9/28/15, 1:57 AM, Matthew Dupre wrote:
> > Hi,
> >
> > I'm interested in the Linux kernel's support for per-flow IPv4 ECMP
> > (i.e. consistent path selection based on a hash of the connection
> > tuple).  I'd been led to believe[1] that this depended on the route
> > cache, which was removed in 3.6.
> >
> > However, I tested a route with multiple next hops on a 3.10 and
> > 3.13 kernel, and ECMP was per-flow!  Obviously I'm pleased that
> > this was the case, but I'd like to understand why this is
> > supported, and whether I can rely on it in future.
> >
> > Could anyone give me a little clarification on whether this is now
> > supported by some means other than the route cache, and whether
> > that support is intended to be continued?
> >
> This is being worked on currently by Peter N=C3=B8rlund
> https://lwn.net/Articles/657431/

Hi,

AFAIK if you create a socket on the machine having the multipath route,
each socket will seemingly be mapped to particular path, and it will
behave as per-flow. But if you use the machine as a router, each packet
is forwarded independently, potentially hitting different paths each
time.

Best Regards
  Peter N=C3=B8rlund
