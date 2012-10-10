From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH 01/12] usbnet: introduce usbnet 3 command helpers
Date: Wed, 10 Oct 2012 11:19:09 +0800
Message-ID: <CACVXFVOPc0gG3UdWqJ0E+6wiwdPv5EoEgbJ0cvJ4oD4602Yp3A@mail.gmail.com>
References: <1349160684-6627-1-git-send-email-ming.lei@canonical.com>
	<1349160684-6627-2-git-send-email-ming.lei@canonical.com>
	<1765908.3QOFSVW2eC@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:46639 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755367Ab2JJDTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 23:19:11 -0400
In-Reply-To: <1765908.3QOFSVW2eC@linux-lqwf.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 9, 2012 at 4:47 PM, Oliver Neukum <oneukum@suse.de> wrote:
>
> Using GFP_KERNEL you preclude using those in resume() and error handling.
> Please pass a gfp_t parameter.

IMO, it is not a big deal because generally only several bytes are to be
allocated inside these helpers.

If you still think the problem should be considered, another candidate fix
is to take GFP_NOIO during system suspend/resume, and take GFP_KERNEL
in other situations.

Thanks,
--
Ming Lei
