From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH v3 3/5] usbnet: smsc95xx: fix memory leak in smsc95xx_suspend
Date: Tue, 6 Nov 2012 21:51:11 +0800
Message-ID: <CACVXFVPhYaBcr+V4W1-fSrLFVMMVo8vUv=eaKu2y_LjZ-EtnwQ@mail.gmail.com>
References: <1352166341-27616-1-git-send-email-ming.lei@canonical.com>
	<1352166341-27616-4-git-send-email-ming.lei@canonical.com>
	<CAKh2mn52HCFE8JSRJZ95m8qimPP0d4hx8SP3yExTsi+RYfJwRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Oliver Neukum <oneukum@suse.de>,
	netdev <netdev@vger.kernel.org>, linux-usb@vger.kernel.org,
	Steve Glendinning <steve.glendinning@shawell.net>
To: Steve Glendinning <steve@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:47685 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343Ab2KFNvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 08:51:13 -0500
In-Reply-To: <CAKh2mn52HCFE8JSRJZ95m8qimPP0d4hx8SP3yExTsi+RYfJwRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 6, 2012 at 9:20 PM, Steve Glendinning <steve@shawell.net> wrote:
> On 6 November 2012 01:45, Ming Lei <ming.lei@canonical.com> wrote:
>> This patch fixes memory leak in smsc95xx_suspend.
>
> Good spot, thanks!
>
> Note that check_warn_return just above your kfree can cause early
> return in the error case, which would still leak filter_mask, so we
> might want to explicitly expand that instance of the helper macro.

OK, will update the patch.

BTW, I just saw the smsc95xx datasheet and the vendor's driver
source code, and found the chip supports runtime PM well
(remote wakeup on 'good packet' or link change), so do you
plan to implement that?

Thanks,
--
Ming Lei
