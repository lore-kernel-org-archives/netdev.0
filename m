From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH 01/12] usbnet: introduce usbnet 3 command helpers
Date: Wed, 10 Oct 2012 13:56:16 +0800
Message-ID: <CACVXFVM7CrxXPYzr+dfWhbbmbF+3sXq4C1q2OauvP6x_jebbYQ@mail.gmail.com>
References: <1349160684-6627-1-git-send-email-ming.lei@canonical.com>
	<1349160684-6627-2-git-send-email-ming.lei@canonical.com>
	<1765908.3QOFSVW2eC@linux-lqwf.site>
	<CACVXFVOPc0gG3UdWqJ0E+6wiwdPv5EoEgbJ0cvJ4oD4602Yp3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:46918 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751154Ab2JJF4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 01:56:18 -0400
In-Reply-To: <CACVXFVOPc0gG3UdWqJ0E+6wiwdPv5EoEgbJ0cvJ4oD4602Yp3A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 10, 2012 at 11:19 AM, Ming Lei <ming.lei@canonical.com> wrote:
> On Tue, Oct 9, 2012 at 4:47 PM, Oliver Neukum <oneukum@suse.de> wrote:
>>
>> Using GFP_KERNEL you preclude using those in resume() and error handling.
>> Please pass a gfp_t parameter.
>
> IMO, it is not a big deal because generally only several bytes are to be
> allocated inside these helpers.

Also pm_restrict_gfp_mask()/pm_restore_gfp_mask() have been introduced
to address the problem for 2 years, looks the gfp_t isn't needed, doesn't it?

Thanks,
--
Ming Lei
