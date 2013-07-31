From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v4 1/5] net/usb/r815x: replace USB buffer from stack to
 DMA-able
Date: Wed, 31 Jul 2013 05:53:53 -0700
Message-ID: <20130731125353.GC30635@kroah.com>
References: <D7C722C73C7A400780358D0376412267@realtek.com.tw>
 <1375262486-5373-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1375262486-5373-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 31, 2013 at 05:21:22PM +0800, Hayes Wang wrote:
> Some USB buffers use stack which may not be DMA-able.
> Use the buffers from kmalloc to replace those one.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
