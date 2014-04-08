From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] decnet: fix possible NULL deref in dnet_select_source()
Date: Mon, 07 Apr 2014 21:51:44 -0700
Message-ID: <1396932704.16584.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5341A3C1.9060101@oracle.com>
	 <1396821554.12330.51.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140407.151854.411047851818388937.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sasha.levin@oracle.com, netdev@vger.kernel.org,
	linux-decnet-user@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, davej@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140407.151854.411047851818388937.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-04-07 at 15:18 -0400, David Miller wrote:

> And in the loopback case, it is the decnet stack's responsibility to
> make sure ->dn_ptr is setup properly, else it should fail the module
> load and stack initialization.
> can fix this properly.

This was based on Sasha report and my limited time.
It seems you have more time than me to spend on decnet !
