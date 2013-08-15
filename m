From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: rfkill: Do not ignore errors from
 regulator_enable()
Date: Thu, 15 Aug 2013 18:17:58 +0200
Message-ID: <1376583478.14084.15.camel@jlt4.sipsolutions.net>
References: <1376518206-10710-1-git-send-email-luis.henriques@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>
To: Luis Henriques <luis.henriques@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1376518206-10710-1-git-send-email-luis.henriques@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-08-14 at 23:10 +0100, Luis Henriques wrote:
> Function regulator_enable() may return an error that has to be checked.
> This patch changes function rfkill_regulator_set_block() so that it checks
> for the return code.  Also, rfkill_data->reg_enabled is set to 'true' only
> if there is no error.

Applied.

johannes
