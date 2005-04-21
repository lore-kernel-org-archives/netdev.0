From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [2.6 patch] drivers/net/skfp/: fix LITTLE_ENDIAN
Date: Wed, 20 Apr 2005 19:42:00 -0700
Message-ID: <20050420194200.4354510e.rddunlap@osdl.org>
References: <20050420021708.GD5489@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux@syskonnect.de, jgarzik@pobox.com, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050420021708.GD5489@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 20 Apr 2005 04:17:08 +0200 Adrian Bunk wrote:

| This patch fixes the LITTLE_ENDIAN #define.
  and a function prototype.

| Signed-off-by: Adrian Bunk <bunk@stusta.de>
| 
| ---
| 
|  drivers/net/skfp/h/osdef1st.h |    2 ++
|  drivers/net/skfp/smt.c        |    2 +-
|  2 files changed, 3 insertions(+), 1 deletion(-)
| 
| --- linux-2.6.12-rc2-mm3-full/drivers/net/skfp/h/osdef1st.h.old	2005-04-20 01:22:21.000000000 +0200
| +++ linux-2.6.12-rc2-mm3-full/drivers/net/skfp/h/osdef1st.h	2005-04-20 01:23:55.000000000 +0200
| @@ -20,6 +20,8 @@
|  // HWM (HardWare Module) Definitions
|  // -----------------------
|  
| +#include <asm/byteorder.h>
| +
|  #ifdef __LITTLE_ENDIAN
|  #define LITTLE_ENDIAN
|  #else
| --- linux-2.6.12-rc2-mm3-full/drivers/net/skfp/smt.c.old	2005-04-20 01:26:34.000000000 +0200
| +++ linux-2.6.12-rc2-mm3-full/drivers/net/skfp/smt.c	2005-04-20 01:26:22.000000000 +0200
| @@ -86,7 +86,7 @@
|  static void smt_send_sif_operation(struct s_smc *smc, struct fddi_addr *dest,
|  				   u_long tid, int local);
|  #ifdef LITTLE_ENDIAN
| -static void smt_string_swap(void);
| +static void smt_string_swap(char *data, const char *format, int len);
|  #endif
|  static void smt_add_frame_len(SMbuf *mb, int len);
|  static void smt_fill_una(struct s_smc *smc, struct smt_p_una *una);
