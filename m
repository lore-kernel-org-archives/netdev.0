From: Gertjan van Wingerde <gwingerde-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 4/8] wireless: Use
	eth_random_addr
Date: Fri, 13 Jul 2012 09:15:06 +0200
Message-ID: <CAL1gcdP+USKVTpQ1+UeLj5VBRtpchCHjP=B=HATpW483f5bCYA@mail.gmail.com>
References: <cover.1342157022.git.joe@perches.com>
	<1341968967.13724.23.camel@joe2Laptop>
	<93ab9a323e85d1b0d8c7eac4db7ab7835e61efe6.1342157022.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	Hin-Tak Leung <htl10-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Herton Ronaldo Krzesinski <herton-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <users-bounces-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org>
In-Reply-To: <93ab9a323e85d1b0d8c7eac4db7ab7835e61efe6.1342157022.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <http://rt2x00.serialmonkey.com/mailman/options/users_rt2x00.serialmonkey.com>,
	<mailto:users-request-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org?subject=unsubscribe>
List-Archive: <http://rt2x00.serialmonkey.com/pipermail/users_rt2x00.serialmonkey.com>
List-Post: <mailto:users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org>
List-Help: <mailto:users-request-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org?subject=help>
List-Subscribe: <http://rt2x00.serialmonkey.com/mailman/listinfo/users_rt2x00.serialmonkey.com>,
	<mailto:users-request-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org?subject=subscribe>
Errors-To: users-bounces-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org
Sender: users-bounces-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 13, 2012 at 7:33 AM, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> wrote:
> Convert the existing uses of random_ether_addr to
> the new eth_random_addr.
>
> Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>

For the rt2x00 parts:

Acked-by: Gertjan van Wingerde <gwingerde-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

> ---
>  drivers/net/wireless/adm8211.c             |    2 +-
>  drivers/net/wireless/p54/eeprom.c          |    2 +-
>  drivers/net/wireless/rt2x00/rt2400pci.c    |    2 +-
>  drivers/net/wireless/rt2x00/rt2500pci.c    |    2 +-
>  drivers/net/wireless/rt2x00/rt2500usb.c    |    2 +-
>  drivers/net/wireless/rt2x00/rt2800lib.c    |    2 +-
>  drivers/net/wireless/rt2x00/rt61pci.c      |    2 +-
>  drivers/net/wireless/rt2x00/rt73usb.c      |    2 +-
>  drivers/net/wireless/rtl818x/rtl8180/dev.c |    2 +-
>  drivers/net/wireless/rtl818x/rtl8187/dev.c |    2 +-
>  10 files changed, 10 insertions(+), 10 deletions(-)
>

---
Gertjan
