From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: mwifiex: fix missing break on IEEE80211_STYPE_ACTION case
Date: Sat,  3 Sep 2016 10:08:44 +0000 (UTC)
Message-ID: <20160903100844.CDF306201B@smtp.codeaurora.org>
References: <1471349413-21893-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Amitkumar Karwar <akarwar@marvell.com>,
        Nishant Sarmukadam <nishants@marvell.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Colin Ian King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471349413-21893-1-git-send-email-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Colin Ian King <colin.king@canonical.com> wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> The IEEE80211_STYPE_ACTION case is missing a break in the switch
> statement, causing it to fall through to the default case that
> reports a debug message about an unknown frame subtype. Fix this
> by adding in the missing break statement.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Thanks, 1 patch applied to wireless-drivers-next.git:

d393be3ed0be mwifiex: fix missing break on IEEE80211_STYPE_ACTION case

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9283755/
