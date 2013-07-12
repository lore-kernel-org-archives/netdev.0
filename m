From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net 2/2] usb/net/r815x: fix cast to restricted __le32
Date: Fri, 12 Jul 2013 16:14:02 -0700 (PDT)
Message-ID: <20130712.161402.460159983188127882.davem@redhat.com>
References: <1373617576-2272-1-git-send-email-hayeswang@realtek.com>
	<1373617576-2272-2-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1373617576-2272-2-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Fri, 12 Jul 2013 16:26:16 +0800

>>> drivers/net/usb/r815x.c:38:16: sparse: cast to restricted __le32
>>> drivers/net/usb/r815x.c:67:15: sparse: cast to restricted __le32
>>> drivers/net/usb/r815x.c:69:13: sparse: incorrect type in assignment (different base types)
>    drivers/net/usb/r815x.c:69:13:    expected unsigned int [unsigned] [addressable] [assigned] [usertype] tmp
>    drivers/net/usb/r815x.c:69:13:    got restricted __le32 [usertype] <noident>
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> Spotted-by: kbuild test robot <fengguang.wu@intel.com>

Applied.
