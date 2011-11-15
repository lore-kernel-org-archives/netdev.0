From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next v4 6/8] forcedeth: account for dropped RX
 frames
Date: Tue, 15 Nov 2011 14:21:30 -0800
Message-ID: <20111115142130.796d52c3@s6510.linuxnetplumber.net>
References: <cover.1321384662.git.david.decotigny@google.com>
	<005cae310e19433c9f68c178805f16c774e8dedd.1321384662.git.david.decotigny@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Richard Jones <rick.jones2@hp.com>,
	Ayaz Abdulla <AAbdulla@nvidia.com>
To: David Decotigny <david.decotigny@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <005cae310e19433c9f68c178805f16c774e8dedd.1321384662.git.david.decotigny@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 15 Nov 2011 11:25:39 -0800
David Decotigny <david.decotigny@google.com> wrote:

> This adds the stats counter for dropped RX frames.
> 

There is already an rx_dropped statistic in netdevice structure,
why do you need your own in ethtool?
