From: Joerg Roedel <joro-lkml@zlug.org>
Subject: Re: [PATCH 00/03][RESUBMIT] net: EtherIP tunnel driver
Date: Sat, 23 Sep 2006 14:27:54 +0200
Message-ID: <20060923122754.GE32284@zlug.org>
References: <20060923120704.GA32284@zlug.org> <20060923121327.GH30245@lug-owl.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ironport-c10.fh-zwickau.de ([141.32.72.200]:22184 "EHLO
	ironport-c10.fh-zwickau.de") by vger.kernel.org with ESMTP
	id S1750825AbWIWM14 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Sep 2006 08:27:56 -0400
To: Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060923121327.GH30245@lug-owl.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 23, 2006 at 02:13:27PM +0200, Jan-Benedict Glaw wrote:

> I haven't seen the first submission, but is this driver really needed?
> Can't this be done with creating two tap interfaces on both endpoints
> and bridge them with a local ethernet device using userland software?

In general it is possible to use a tap interface to tunnel Ethernet
packets. But this driver uses the EtherIP protocol defined in RFC 3378
which itself defines an own IP protocol for it (number 97). This
protocol is also supported by different other operating systems (some of
the major BSD versions). This driver makes Linux interoperable with
these implementations.

Regards,
    Joerg Roedel
