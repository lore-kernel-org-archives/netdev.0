From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: netconsole fun
Date: Thu, 13 Dec 2012 10:33:55 +0000 (UTC)
Message-ID: <kacauj$en0$1@ger.gmane.org>
References: <1355149033.3142.14.camel@thor> <ka6e4e$6k5$1@ger.gmane.org>
 <1355235592.2694.5.camel@thor>
 <20121211143004.GA7481@neilslaptop.think-freely.org>
 <1355239011.2694.24.camel@thor>
 <20121211164526.GB7481@neilslaptop.think-freely.org>
 <1355345957.2687.18.camel@thor>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:53275 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752800Ab2LMKeS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2012 05:34:18 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Tj67Q-0004z8-VE
	for netdev@vger.kernel.org; Thu, 13 Dec 2012 11:34:21 +0100
Received: from 112.122.183.103 ([112.122.183.103])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2012 11:34:20 +0100
Received: from xiyou.wangcong by 112.122.183.103 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2012 11:34:20 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Dec 2012 at 20:59 GMT, Peter Hurley <peter@hurleysoftware.com> wrote:
>
> Just wondering if you think something like the patch below is
> suitable/acceptable for insulating netconsole from inconsistent device
> name scenarios without changing the existing semantics. The basic idea
> is to allow an ethernet MAC address in the <dev> field of the
> netconsole= options, and if a MAC address was specified rather than a
> device name, to do the dev lookup from the MAC address instead.
>
> This doesn't extend to, but also doesn't interfere with, the dynamic
> config of netconsole via configfs.
>
> Would you mind reviewing it?
>

This is a good idea. Just that you need to complete the configfs
interface too.
