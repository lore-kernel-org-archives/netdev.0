From: "Zhao\, Gang" <gamerh2o@gmail.com>
Subject: Re: [PATCH 02/13] staging: r8188eu: Remove pointless "alignment"
 entry in recv_frame
Date: Sun, 16 Feb 2014 11:02:52 +0800
Message-ID: <87ob27bvz7.fsf@will.lan>
References: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
 <1392418457-3203-3-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, gregkh@linuxfoundation.org,
 Jes.Sorensen@redhat.com, netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1392418457-3203-3-git-send-email-Larry.Finger@lwfinger.net>
 (Larry Finger's message of "Fri, 14 Feb 2014 16:54:06 -0600")
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

On Sat, 2014-02-15 at 06:54:06 +0800, Larry Finger wrote:
> This alignment entry in union recv_frame does nothing. It certainly
> dues not ensure alignment.
   ^
   typo here.

   I accidently sent this as a private mail before, better to resend to
   the list.

>
> Suggested-by: Jes.Sorensen@redhat.com
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> Cc: Jes.Sorensen@redhat.com
> ---
>  drivers/staging/rtl8188eu/include/rtw_recv.h | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/drivers/staging/rtl8188eu/include/rtw_recv.h b/drivers/staging/rtl8188eu/include/rtw_recv.h
> index 866c9e4..c6d7a65 100644
> --- a/drivers/staging/rtl8188eu/include/rtw_recv.h
> +++ b/drivers/staging/rtl8188eu/include/rtw_recv.h
> @@ -292,7 +292,6 @@ struct recv_frame_hdr {
>  union recv_frame {
>  	union {
>  		struct recv_frame_hdr hdr;
> -		uint mem[RECVFRAME_HDR_ALIGN>>2];
>  	} u;
>  };
