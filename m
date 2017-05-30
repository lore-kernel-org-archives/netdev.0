From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2] mac80211: Invoke TX LED in more code paths
Date: Tue, 30 May 2017 09:18:28 +0200
Message-ID: <1496128708.3327.0.camel@sipsolutions.net>
References: <20170527215927.7726-1-bjorn.andersson@linaro.org>
         (sfid-20170527_235932_534835_9EAE8FC2)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "open list:MAC80211" <linux-wireless@vger.kernel.org>,
        "open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>,
        linux-arm-msm@vger.kernel.org
To: Bjorn Andersson <bjorn.andersson@linaro.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <20170527215927.7726-1-bjorn.andersson@linaro.org> (sfid-20170527_235932_534835_9EAE8FC2)
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2017-05-27 at 14:59 -0700, Bjorn Andersson wrote:
> ieee80211_tx_status() is only one of the possible ways a driver can
> report a handled packet, some drivers call this for every packet
> while
> others calls it rarely or never.
> 
> In order to invoke the TX LED in the non-status reporting cases this
> patch pushes the call to ieee80211_led_tx() into
> ieee80211_report_used_skb(), which is shared between the various code
> paths.

Applied.

johannes
