From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/15] ethernet: use core min/max MTU checking
Date: Tue, 18 Oct 2016 11:34:38 -0400 (EDT)
Message-ID: <20161018.113438.62003626132979588.davem@davemloft.net>
References: <20161017195417.48259-1-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161017195417.48259-1-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarod Wilson <jarod@redhat.com>
Date: Mon, 17 Oct 2016 15:54:02 -0400

> Now that the network stack core min/max MTU checking infrastructure is in
> place, time to start making drivers use it. We'll start with the easiest
> ones, the ethernet drivers, split roughly by vendor, with a catch-all
> patch at the end.
> 
> For the most part, every patch does the same essential thing: removes the
> MTU range checking from the drivers' ndo_change_mtu function, puts those
> ranges into the core net_device min_mtu and max_mtu fields, and where
> possible, removes ndo_change_mtu functions entirely.
> 
> These patches have all been built through the 0-day build infrastructure
> provided by Intel, on top of net-next as of October 17.

Series applied, thanks Jarod.
