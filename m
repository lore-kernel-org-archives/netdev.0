From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v3 1/3] net/usb/r815x: replace USB buffer from stack to
 DMA-able
Date: Tue, 30 Jul 2013 06:58:28 -0700
Message-ID: <20130730135828.GD27962@kroah.com>
References: <D7C722C73C7A400780358D0376412267@realtek.com.tw>
 <1375172936-4145-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org, nic_swsd@realtek.com
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:40451 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753080Ab3G3N5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 09:57:10 -0400
Content-Disposition: inline
In-Reply-To: <1375172936-4145-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 30, 2013 at 04:28:54PM +0800, Hayes Wang wrote:
> Allocate the transfer buffer in probe(), and use the buffer for
> usb control transfer.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>  drivers/net/usb/r815x.c | 117 +++++++++++++++++++++++++++++++++++++-----------
>  1 file changed, 90 insertions(+), 27 deletions(-)

In the future, you do not need to send drivers/net/usb/ patches to me,
netdev and the linux-usb mailing lists should be sufficient.

thanks,

greg k-h
