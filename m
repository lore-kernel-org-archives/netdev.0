From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: Re: Fw: [PATCH net-next] drivers/s390/net/qeth_l3_main.c: Use %pI6
Date: Thu, 12 Aug 2010 18:36:00 +0200
Message-ID: <1281630960.12375.8.camel@braunu-laptop>
References: <OF89C50871.5ED34E2A-ONC125777D.005A40DE-C125777D.005A4DDE@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: blaschka@linux.vnet.ibm.com, linux-s390@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ursula Braun1 <ursula.braun@de.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <OF89C50871.5ED34E2A-ONC125777D.005A40DE-C125777D.005A4DDE@de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ACK
Thanks Joe - we make sure your patch is submitted to Dave Miller within
our next submission of qeth patches.

Ursula

> From:     Joe Perches <joe@perches.com>
> To:       Frank Blaschka <blaschka@linux.vnet.ibm.com>
> Subject:  [PATCH net-next] drivers/s390/net/qeth_l3_main.c: Use %pI6

> Format an ipv6 address using vsprintf extensions.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> drivers/s390/net/qeth_l3_main.c |    7 +------
> 1 files changed, 1 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/s390/net/qeth_l3_main.c
> b/drivers/s390/net/qeth_l3_main.c
> index e22ae24..561bdc8 100644
> --- a/drivers/s390/net/qeth_l3_main.c
> +++ b/drivers/s390/net/qeth_l3_main.c
> @@ -103,12 +103,7 @@ int qeth_l3_string_to_ipaddr4(const char *buf,
> __u8 *addr)
> 
> void qeth_l3_ipaddr6_to_string(const __u8 *addr, char *buf)
> {
> -                 sprintf(buf, "%02x%02x:%02x%02x:%02x%02x:%02x%02x"
> -                                       ":%02x%02x:%02x%02x:%02x%02x:%
> 02x%02x",
> -                                       addr[0], addr[1], addr[2],
> addr[3],
> -                                       addr[4], addr[5], addr[6],
> addr[7],
> -                                       addr[8], addr[9], addr[10],
> addr[11],
> -                                       addr[12], addr[13], addr[14],
> addr[15]);
> +                 sprintf(buf, "%pI6", addr);
> }
> 
> int qeth_l3_string_to_ipaddr6(const char *buf, __u8 *addr)
> 
> 
