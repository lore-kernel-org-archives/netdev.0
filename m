From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: fix possible NULL pointer dereference
Date: Sun, 27 Mar 2011 11:17:36 +0200
Message-ID: <1301217456.3826.3.camel@jlt3.sipsolutions.net>
References: <1301162331-5236-1-git-send-email-mk@lab.zgora.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mariusz Kozlowski <mk@lab.zgora.pl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1301162331-5236-1-git-send-email-mk@lab.zgora.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2011-03-26 at 18:58 +0100, Mariusz Kozlowski wrote:
> This patch moves 'key' dereference after BUG_ON(!key) so that when key is NULL
> we will see proper trace instead of oops.
> 
> Signed-off-by: Mariusz Kozlowski <mk@lab.zgora.pl>

Acked-by: Johannes Berg <johannes@sipsolutions.net>

I guess, not that it matters much since it's extremely unlikely somebody
will attemt to misuse this function :-)

johannes
