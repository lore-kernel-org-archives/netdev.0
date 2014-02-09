From: Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>
Subject: Re: [PATCH 09/28] Remove ATHEROS_AR231X
Date: Sun, 09 Feb 2014 20:18:24 +0100
Message-ID: <52F7D480.1050106@hauke-m.de>
References: <1391971686-9517-1-git-send-email-richard@nod.at>
	<1391971686-9517-10-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"open list:ATHEROS ATH5K WIR..." <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"open list:ATHEROS ATH5K WIR..." <ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org>,
	open-5/S+JYg5SzeELgA04lAiVw@public.gmane.org,
	list-5/S+JYg5SzeELgA04lAiVw@public.gmane.org:NETWORKING DRIVERS <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org>
In-Reply-To: <1391971686-9517-10-git-send-email-richard-/L3Ra7n9ekc@public.gmane.org>
List-Unsubscribe: <https://lists.ath5k.org/mailman/listinfo/ath5k-devel>,
	<mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ath5k.org/pipermail/ath5k-devel>
List-Post: <mailto:ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org>
List-Help: <mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ath5k.org/mailman/listinfo/ath5k-devel>,
	<mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=subscribe>
Sender: ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org
Errors-To: ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 02/09/2014 07:47 PM, Richard Weinberger wrote:
> The symbol is an orphan, get rid of it.
> 
> Signed-off-by: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
> ---
>  drivers/net/wireless/ath/ath5k/Kconfig | 10 +++++-----
>  drivers/net/wireless/ath/ath5k/ath5k.h | 28 ----------------------------
>  drivers/net/wireless/ath/ath5k/base.c  | 14 --------------
>  drivers/net/wireless/ath/ath5k/led.c   |  7 -------
>  4 files changed, 5 insertions(+), 54 deletions(-)
> 

This code is used in OpenWrt with an out of tree arch code for the
Atheros 231x/531x SoC. [0] I do not think anyone is working on adding
this code to mainline Linux kernel, because of lack of time/interest.

Hauke

[0]: https://dev.openwrt.org/browser/trunk/target/linux/atheros/patches-3.10
