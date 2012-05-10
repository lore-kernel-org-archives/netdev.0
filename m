From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: device - added support of clearing device
 statistics
Date: Thu, 10 May 2012 17:18:27 +0200
Message-ID: <1336663107.12504.155.camel@edumazet-glaptop>
References: <1336662961-15033-1-git-send-email-sasikanth.v19@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Jiri Pirko <jpirko@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sasikantha babu <sasikanth.v19@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1336662961-15033-1-git-send-email-sasikanth.v19@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-05-10 at 20:46 +0530, Sasikantha babu wrote:
> This patch adds the support of clearing device statistics. Added new 
> entry ndo_clear_stats to net_device_ops for device drivers to provide
> there own method to clear stats otherwise internal statistics structure
> is cleared.
> 
> Signed-off-by: Sasikantha babu <sasikanth.v19@gmail.com>

This is forbidden and racy.

SNMP counters must be increasing.
