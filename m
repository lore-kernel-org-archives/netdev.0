From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net 5/5] bnx2x: fix VLAN configuration for VFs.
Date: Sun, 5 Jan 2014 21:19:01 +0200
Message-ID: <CAJZOPZJ7NQZspnNksr=w9Yo1MtgstLhVbqwxUWE0k+tbhCaO4g@mail.gmail.com>
References: <1388939634-19948-1-git-send-email-yuvalmin@broadcom.com>
	<1388939634-19948-6-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	ariele@broadcom.com
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:47226 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304AbaAETTC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 14:19:02 -0500
Received: by mail-pa0-f54.google.com with SMTP id rd3so17906766pab.27
        for <netdev@vger.kernel.org>; Sun, 05 Jan 2014 11:19:01 -0800 (PST)
In-Reply-To: <1388939634-19948-6-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 5, 2014 at 6:33 PM, Yuval Mintz <yuvalmin@broadcom.com> wrote:
> If the hypervisor configures a vlan for the VF via the PF, the expected
> result is that only packets tagged by said vlan will be received by the VF
> (and that vlan will be silently removed).
> Do to an incorrect manipulation of vlan filters in the driver, the

Did you want to say "Due to an incorrect"?

> VF can receive untagged traffic even if the hypervisor configured
> some vlan for it.
