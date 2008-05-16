From: Olaf Hering <olaf@aepfle.de>
Subject: Re: dead network on JS21 with tg3 driver after flowcontrol changes
Date: Fri, 16 May 2008 10:13:30 +0200
Message-ID: <20080516081330.GA26530@aepfle.de>
References: <20080515121340.GA23033@aepfle.de> <20080515171520.GA20953@localdomain> <1210881078.22745.9.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Matt Carlson <mcarlson@broadcom.com>, linuxppc-dev@ozlabs.org,
	netdev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:33889 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755426AbYEPINd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 04:13:33 -0400
Content-Disposition: inline
In-Reply-To: <1210881078.22745.9.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 15, Michael Chan wrote:

> Matt, I think that's very likely the problem.  If we are trying to
> establish link in parallel detect mode, the flow control settings may
> not match.  If we do not enter the if statement to do nothing, we will
> keep autonegotiating forever and never establish link.

Yes, this patch fixes nfsroot for me. Thanks.
mii-tool is not shipped anymore, even in SLES10.
I assume that ethtool is the replacement?

Olaf
