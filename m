From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2/2] mac80211: use accessor functions to set sta->_flags
Date: Tue, 24 Jan 2017 16:44:28 +0100
Message-ID: <1485272668.1236.5.camel@sipsolutions.net>
References: <1485272531-11587-1-git-send-email-amadeusz.slawinski@tieto.com>
         <1485272531-11587-2-git-send-email-amadeusz.slawinski@tieto.com>
         (sfid-20170124_164229_076986_6C281934)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Amadeusz =?UTF-8?Q?S=C5=82awi=C5=84ski?=
        <amadeusz.slawinski@tieto.com>, linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485272531-11587-2-git-send-email-amadeusz.slawinski@tieto.com> (sfid-20170124_164229_076986_6C281934)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-01-24 at 16:42 +0100, Amadeusz Sławiński wrote:
> cleanup patch to make use of set_sta_flag()/clear_sta_flag() in
> places
> where we access sta->_flags
> 
> Signed-off-by: Amadeusz Sławiński <amadeusz.slawinski@tieto.com>
> ---
>  net/mac80211/sta_info.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
> index b6cfcf0..6c9cc2f 100644
> --- a/net/mac80211/sta_info.c
> +++ b/net/mac80211/sta_info.c
> @@ -1855,13 +1855,13 @@ int sta_info_move_state(struct sta_info *sta,
>  	switch (new_state) {
>  	case IEEE80211_STA_NONE:
>  		if (sta->sta_state == IEEE80211_STA_AUTH)
> -			clear_bit(WLAN_STA_AUTH, &sta->_flags);
> +			clear_sta_flag(sta, WLAN_STA_AUTH);

You should try to run this patch sometime :)

johannes
