From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [PATCH 1/3] Kernel interfaces for multiqueue aware socket
Date: Wed, 15 Dec 2010 18:43:36 -0800
Message-ID: <4D097CD8.7080902@chelsio.com>
References: <cover.1292405004.git.fenghua.yu@intel.com> <46a08278c2ba21737528eb4b77391a7e8bc88000.1292405004.git.fenghua.yu@intel.com> <1292446118.2603.11.camel@edumazet-laptop> <20101216011425.GA17446@linux-os.sc.intel.com> <AANLkTingt6SM+uasicwPSJRE5vYpvJ=GyFf3bbKhO72G@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Fenghua Yu <fenghua.yu@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	"Tang, Xinan" <xinan.tang@intel.com>,
	Junchang Wang <junchangwang@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTingt6SM+uasicwPSJRE5vYpvJ=GyFf3bbKhO72G@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changli Gao wrote:
> On Thu, Dec 16, 2010 at 9:14 AM, Fenghua Yu <fenghua.yu@intel.com> wrote:
>> SKF_AD_QUEUE doesn't know number of rx queues. Thus user application can't
>> specify right SKF_AD_QUEUE.
> 
> It is wrong. AFAIK, you can get the queue number through
> /sys/class/net/eth*/queues/ or /proc/interrupts

The number of Rx queues is also available through ETHTOOL_GRXRINGS though 
few drivers support it currently.
