From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hyperv: Implement netvsc_get_channels()
 ethool op
Date: Sat, 28 Feb 2015 16:52:00 -0500 (EST)
Message-ID: <20150228.165200.1472902190649725857.davem@davemloft.net>
References: <1424996834-6684-1-git-send-email-andrew@schwartzmeyer.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: haiyangz@microsoft.com, kys@microsoft.com,
	devel@linuxdriverproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, hall5714@vandals.uidaho.edu,
	keithd@vandals.uidaho.edu, doma8101@vandals.uidaho.edu
To: andrew@schwartzmeyer.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424996834-6684-1-git-send-email-andrew@schwartzmeyer.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Schwartzmeyer <andrew@schwartzmeyer.com>
Date: Thu, 26 Feb 2015 16:27:14 -0800

> This adds support for reporting the actual and maximum combined channels
> count of the hv_netvsc driver via 'ethtool --show-channels'.
> 
> This required adding 'max_chn' to 'struct netvsc_device', and assigning
> it 'rsscap.num_recv_que' in 'rndis_filter_device_add'. Now we can access
> the combined maximum channel count via 'struct netvsc_device' in the
> ethtool callback.
> 
> Signed-off-by: Andrew Schwartzmeyer <andrew@schwartzmeyer.com>

Applied, thanks.
