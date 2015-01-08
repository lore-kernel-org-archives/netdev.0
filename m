From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH net-next] mac80211: silent build warnings
Date: Thu, 08 Jan 2015 15:59:43 +0300
Message-ID: <54AE7F3F.3070802@cogentembedded.com>
References: <1420700655-9427-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ying Xue <ying.xue-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1420700655-9427-1-git-send-email-ying.xue-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 1/8/2015 10:04 AM, Ying Xue wrote:

> Silent the following build warnings:

> net/mac80211/mlme.c: In function =E2=80=98ieee80211_rx_mgmt_beacon=E2=
=80=99:
> net/mac80211/mlme.c:1348:3: warning: =E2=80=98pwr_level_cisco=E2=80=99=
 may be used uninitialized in this function [-Wuninitialized]
> net/mac80211/mlme.c:1315:6: note: =E2=80=98pwr_level_cisco=E2=80=99 w=
as declared here

> Signed-off-by: Ying Xue <ying.xue-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
> ---
>   net/mac80211/mlme.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

> diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
> index 2c36c47..13b5506 100644
> --- a/net/mac80211/mlme.c
> +++ b/net/mac80211/mlme.c
> @@ -1312,7 +1312,7 @@ static u32 ieee80211_handle_pwr_constr(struct i=
eee80211_sub_if_data *sdata,
>   {
>   	bool has_80211h_pwr =3D false, has_cisco_pwr =3D false;
>   	int chan_pwr =3D 0, pwr_reduction_80211h =3D 0;
> -	int pwr_level_cisco, pwr_level_80211h;
> +	int pwr_level_cisco =3D 0, pwr_level_80211h =3D 0;

    OK, but why are you also initializing the second variable?

WBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
