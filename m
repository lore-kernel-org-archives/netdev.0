From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] bonding: add the sysfs interface to see RLB hash table
Date: Tue, 30 Nov 2010 14:08:35 -0800
Message-ID: <20101130140835.7320e9e4@nehalam>
References: <4CF4CB85.4010708@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <fubar@us.ibm.com>
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52696 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752400Ab0K3WIi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Nov 2010 17:08:38 -0500
In-Reply-To: <4CF4CB85.4010708@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Nov 2010 19:01:41 +0900
Taku Izumi <izumi.taku@jp.fujitsu.com> wrote:

> # cat /sys/class/net/bond0/bonding/rlb_hash_table
> 
> SourceIP        DestinationIP   Destination MAC   DEV
>  10.124.196.205  10.124.196. 81 00:19:99:XX:XX:XX eth3
>  10.124.196.205  10.124.196.222 00:0a:79:XX:XX:XX eth0
>  10.124.196.205  10.124.196. 75 00:15:17:XX:XX:XX eth4
>  10.124.196.205  10.124.196.  1 00:21:d8:XX:XX:XX eth3
>  10.124.196.205  10.124.196.205 ff:ff:ff:ff:ff:ff eth0

This violates the one value per file convention of sysfs.
It belongs in /proc. Unfortunately there already is a /proc/net/bonding/bond0
but it is a file not a directory.


-- 
