From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: rename and move busy poll mib counter
Date: Tue, 06 Aug 2013 03:14:48 -0700
Message-ID: <1375784088.4457.74.camel@edumazet-glaptop>
References: <20130806095207.5887.2196.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130806095207.5887.2196.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-08-06 at 12:52 +0300, Eliezer Tamir wrote:
> Move the low latency mib counter to the ip section.
> Rename it from low latency to busy poll.
> 
> Reported-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> ---

Well, it should not be part of IP mib, but a socket one (not existing so
far)

Linux MIB already contains few non TCP counters :

LINUX_MIB_ARPFILTER
LINUX_MIB_IPRPFILTER

Its mostly populated by TCP counters, sure.
