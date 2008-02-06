From: Josh Boyer <jwboyer@gmail.com>
Subject: Re: [PATCH] net: NEWEMAC: Remove "rgmii-interface" from rgmii
 matching table
Date: Wed, 6 Feb 2008 10:23:40 -0600
Message-ID: <20080206102340.1cdf7f8d@zod.rchland.ibm.com>
References: <1202300519-7294-1-git-send-email-sr@denx.de>
	<20080206160157.GA18228@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stefan Roese <sr@denx.de>, linuxppc-dev@ozlabs.org,
	jeff@garzik.org, netdev@vger.kernel.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.179]:33650 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895AbYBFQYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 11:24:04 -0500
Received: by ik-out-1112.google.com with SMTP id c28so398524ika.5
        for <netdev@vger.kernel.org>; Wed, 06 Feb 2008 08:24:03 -0800 (PST)
In-Reply-To: <20080206160157.GA18228@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 6 Feb 2008 10:01:57 -0600
Olof Johansson <olof@lixom.net> wrote:

> On Wed, Feb 06, 2008 at 01:21:59PM +0100, Stefan Roese wrote:
> > With the removal the the "rgmii-interface" device_type property from the
> > dts files, the newemac driver needs an update to only rely on compatible
> > property.
> 
> What about systems using an older dts, such as one kexec:ing from an
> older kernel?

Like what?  Kexec doesn't work on 4xx yet.

> Just because the device tree source is distributed in the kernel tree
> doesn't mean it can give up backwards compatibility.

We checked Axon, which is the only non-DTS machine that uses EMAC and
it will work fine with this change.

josh
