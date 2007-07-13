From: KII Keiichi <k-keiichi@bx.jp.nec.com>
Subject: Re: [PATCH v2 -mm 6/9] netconsole: Introduce netconsole_netdev_notifier
Date: Fri, 13 Jul 2007 22:47:11 +0900
Message-ID: <4697825F.3030101@bx.jp.nec.com>
References: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in> <20070710091951.23907.36072.sendpatchset@cselinux1.cse.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Matt Mackall <mpm@selenic.com>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:56618 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757226AbXGMNtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2007 09:49:22 -0400
In-Reply-To: <20070710091951.23907.36072.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Satyam,

> From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
> 
> [6/9] netconsole: Introduce netconsole_netdev_notifier
> 
> To update fields of underlying netpoll structure at runtime on
> corresponding NETDEV_CHANGEADDR or NETDEV_CHANGENAME notifications.
> 
> ioctl(SIOCSIFHWADDR) {or ioctl(SIOCSIFNAME)} could be used to change the
> hardware/MAC address {or name} of the local interface that our netpoll is
> attached to. Whenever this happens, netdev notifier chain is called out
> with the NETDEV_CHANGEADDR {or NETDEV_CHANGENAME} event message. We respond
> to that and update the local_mac {or dev_name} field of the struct netpoll.
> This makes sense anyway, but is especially required for dynamic netconsole
> because the netpoll structure's internal members become user visible files
> when either sysfs or configfs are used. So this helps us to keep up with the
> MAC address / name changes and keep the values in struct netpoll uptodate.
> 
> Signed-off-by: Satyam Sharma <ssatyam@cse.iitk.ac.in>
> Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>
> 
Signed-off-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>

Thanks
--
Keiichi KII
NEC Corporation OSS Platform Development Division
E-mail: k-keiichi@bx.jp.nec.com

