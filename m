From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211_hwsim: release driver when
 ieee80211_register_hw fails
Date: Wed, 29 Oct 2014 16:31:20 +0100
Message-ID: <1414596680.1827.6.camel@jlt4.sipsolutions.net>
References: <1414459907-7509-1-git-send-email-eternal.n08@gmail.com>
	 (sfid-20141028_023301_948024_70359C07)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Martin Pitt <martin.pitt@ubuntu.com>,
	Fengguang Wu <fengguang.wu@intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Junjie Mao <eternal.n08@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414459907-7509-1-git-send-email-eternal.n08@gmail.com> (sfid-20141028_023301_948024_70359C07)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-10-28 at 09:31 +0800, Junjie Mao wrote:
> The driver is not released when ieee80211_register_hw fails in
> mac80211_hwsim_create_radio, leading to the access to the unregistered (and
> possibly freed) device in platform_driver_unregister:

Applied.

johannes
