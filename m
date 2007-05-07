From: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2] Add rtl8187 wireless driver
Date: Mon, 07 May 2007 11:25:26 -0400
Message-ID: <463F44E6.5030705@garzik.org>
References: <200705071022.11711.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Andrea Merello <andrea.merello-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200705071022.11711.flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Michael Wu wrote:
> This patch adds a mac80211 based wireless driver for the rtl8187 USB
> wireless card.
> 
> Signed-off-by: Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
> ---
> 
>  MAINTAINERS                                    |   10 
>  drivers/net/wireless/Kconfig                   |    2 
>  drivers/net/wireless/Makefile                  |    3 
>  drivers/net/wireless/rtl818x/Kconfig           |   16 +
>  drivers/net/wireless/rtl818x/Makefile          |    2 
>  drivers/net/wireless/rtl818x/rtl8187.h         |  125 ++++
>  drivers/net/wireless/rtl818x/rtl8187_dev.c     |  730 ++++++++++++++++++++++++
>  drivers/net/wireless/rtl818x/rtl8187_rtl8225.c |  744 ++++++++++++++++++++++++
>  drivers/net/wireless/rtl818x/rtl8187_rtl8225.h |   30 +
>  drivers/net/wireless/rtl818x/rtl818x.h         |  212 +++++++
>  10 files changed, 1874 insertions(+), 0 deletions(-)

Much better.

For the record, new wireless drivers go TO John Linville for merging 
(and he pushes to me, in turn).

I am a bit skeptical that multiple files are needed.  It seems like 
drivers/net/wireless/rtl818x.c would be a better path, a la tg3.c.

	Jeff
