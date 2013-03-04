From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 1/5] net: implement support for low latency socket
 polling
Date: Mon, 04 Mar 2013 06:52:48 -0800
Message-ID: <1362408768.15793.89.camel@edumazet-glaptop>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
	  <20130227175555.10611.42794.stgit@gitlad.jf.intel.com>
	 <1362335704.15793.81.camel@edumazet-glaptop>
	 <51345EB8.9050309@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eliezer Tamir <eliezer.tamir@linux.jf.intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51345EB8.9050309@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-03-04 at 10:43 +0200, Eliezer Tamir wrote:

> One could for example increment the generation id every time the RTNL is 
> taken. or is this too much?

RTNL is taken for a lot of operations, it would be better to have a
finer grained increment.
