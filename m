From: Bart Van Assche <bvanassche@acm.org>
Subject: Re: software iwarp stack update
Date: Thu, 16 Jun 2011 18:54:32 +0200
Message-ID: <BANLkTinwQ2AdV3EOxNcGDZdEsxfa5fhJ0w@mail.gmail.com>
References: <BANLkTimEGgKEMZd3qppOofN-Vj-u-PH-xA@mail.gmail.com> <OFB7458EEB.BFB8A4EE-ONC12578B1.004026D1-C12578B1.0041190E@ch.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-rdma@vger.kernel.org, linux-rdma-owner@vger.kernel.org,
	netdev@vger.kernel.org
To: Bernard Metzler <BMT@zurich.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:50816 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932090Ab1FPQyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 12:54:53 -0400
In-Reply-To: <OFB7458EEB.BFB8A4EE-ONC12578B1.004026D1-C12578B1.0041190E@ch.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 16, 2011 at 1:51 PM, Bernard Metzler <BMT@zurich.ibm.com> wrote:
> > Also, the following statement in siw_main.c:
> >
> > ibdev->modify_port = NULL;
>
> I was expecting there is an ib_device->uverbs_cmd_mask
> flag which siw does not set... Unfortunately, it is not
> completely clear to me when a command mask bit is available
> and when the OFA core strictly expects a function pointer.
> Maybe there is some redundancy/inconsistency?

If other iWARP drivers (amso, cxgb3) have a modify_port method, why
doesn't the siw driver have such a method ? I see this as a blocking
issue.

Bart.
