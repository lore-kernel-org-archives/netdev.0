From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH v4 4/5] net/usb/r8152: make sure the USB buffer is
 DMA-able
Date: Wed, 31 Jul 2013 05:54:53 -0700
Message-ID: <20130731125453.GD30635@kroah.com>
References: <D7C722C73C7A400780358D0376412267@realtek.com.tw>
 <1375262486-5373-1-git-send-email-hayeswang@realtek.com>
 <1375262486-5373-4-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1375262486-5373-4-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 31, 2013 at 05:21:25PM +0800, Hayes Wang wrote:
> Allocate the required memory before calling usb_control_msg. And
> the additional memory copy is necessary.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
