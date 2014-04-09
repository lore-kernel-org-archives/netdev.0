From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 2/3] staging: r8188eu: Fix case where ethtype was never
 obtained and always be checked against 0
Date: Wed, 9 Apr 2014 22:44:57 +0300
Message-ID: <20140409194457.GK4963@mwanda>
References: <1397059980-11942-1-git-send-email-Larry.Finger@lwfinger.net>
 <1397059980-11942-3-git-send-email-Larry.Finger@lwfinger.net>
 <53457428.4030408@cogentembedded.com>
 <20140409190204.GD26890@mwanda>
 <53459B78.7090709@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, gregkh@linuxfoundation.org,
 netdev@vger.kernel.org, Stable <stable@vger.kernel.org>,
 Larry Finger <Larry.Finger@lwfinger.net>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <53459B78.7090709@cogentembedded.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 09, 2014 at 11:11:52PM +0400, Sergei Shtylyov wrote:
> On 04/09/2014 11:02 PM, Dan Carpenter wrote:
> 
> >>>diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
> >>>index 01fcabc..61084d6 100644
> >>>--- a/drivers/staging/rtl8188eu/core/rtw_recv.c
> >>>+++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
> >>>@@ -551,7 +551,7 @@ static struct recv_frame *portctrl(struct adapter *adapter,
> >>>  	struct sta_info *psta;
> >>>  	struct sta_priv *pstapriv;
> >>>  	struct recv_frame *prtnframe;
> >>>-	u16	ether_type = 0;
> >>>+	u16	ether_type;
> 
> >>    I suggest:
> 
> >>	u16 ethertype;
> 
> >I don't understand this suggestion.  Why is that name prefered?
> 
>    Sorry, I've managed to somehow remove the underscore. :-/
> My real suggestion was to replace the tab with a space.

Ah, sure.

regards,
dan carpenter
