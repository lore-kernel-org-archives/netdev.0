From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: fix invalid read in
 minstrel_sort_best_tp_rates()
Date: Thu, 13 Aug 2015 13:53:10 +0200
Message-ID: <1439466790.2114.21.camel@sipsolutions.net>
References: <1438072216-19228-1-git-send-email-adrien+dev@schischi.me>
	 (sfid-20150728_103052_520611_9034FF48)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrien Schildknecht <adrien+dev@schischi.me>, davem@davemloft.net,
	thomas@net.t-labs.tu-berlin.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438072216-19228-1-git-send-email-adrien+dev@schischi.me> (sfid-20150728_103052_520611_9034FF48)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-07-28 at 10:30 +0200, Adrien Schildknecht wrote:
> At the last iteration of the loop, j may equal zero and thus
> tp_list[j - 1] causes an invalid read.
> Changed the logic of the loop so that j - 1 is always >= 0.
> 
> Signed-off-by: Adrien Schildknecht <adrien+dev@schischi.me>
> 
Applied, I added Cc stable.

johannes
