From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.4.28-pre4-bk3] forcedeth: Gigabit ethernet support and
 media detection changes
Date: Sun, 17 Oct 2004 09:46:31 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <417277B7.8000705@pobox.com>
References: <Pine.LNX.4.44.0410171216490.29815-100000@dbl.q-ag.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: marcelo.tosatti@cyclades.com, blazara@nvidia.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Manfred Spraul <manfred@colorfullife.com>
In-Reply-To: <Pine.LNX.4.44.0410171216490.29815-100000@dbl.q-ag.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Manfred Spraul wrote:
> Backport of the 0.29 forcedeth driver to 2.4.
> Changes:
> - lots of bugfixes.
> - completely rewritten PHY initialization and media detection
> - gigabit ethernet support
> 
> The actual backport was done by Jane Liu from NVIDIA:
> 
> - all occurrences of msleep changed to mdelay

NAK, mdelay(500) isn't acceptable.  Use schedule_timeout or add msleep 
to 2.4.x.


> - SET_NETDEV_DEV calls removed

NAK, SET_NETDEV_DEV() exists in 2.4.x


> - module_param call changed to MODULE_PARM

OK

	Jeff
