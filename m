From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211_hwsim: unregister genetlink family properly
Date: Thu, 13 Aug 2015 15:10:47 +0200
Message-ID: <1439471447.2114.29.camel@sipsolutions.net>
References: <1438937650-361-1-git-send-email-cantona@cantona.net>
	 (sfid-20150807_105718_504752_78954283)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Su Kang Yin <cantona@cantona.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438937650-361-1-git-send-email-cantona@cantona.net> (sfid-20150807_105718_504752_78954283)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-08-07 at 16:54 +0800, Su Kang Yin wrote:
> During hwsim_init_netlink(), we should call genl_unregister_family()
> if failed on netlink_register_notifier() since the genetlink is
> already registered.
> 
Applied.

johannes
