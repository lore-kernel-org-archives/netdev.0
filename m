From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: /proc/net/igmp group address encoding
Date: Wed, 24 Sep 2008 14:20:48 +0300 (EEST)
Message-ID: <alpine.LRH.2.00.0809241418060.31969@netcore.fi>
References: <alpine.LRH.2.00.0809241326070.30892@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:47925 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751437AbYIXLUw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 07:20:52 -0400
Received: from netcore.fi (localhost [127.0.0.1])
	by netcore.fi (8.13.8/8.13.8) with ESMTP id m8OBKmtY032050
	for <netdev@vger.kernel.org>; Wed, 24 Sep 2008 14:20:48 +0300
Received: from localhost (pekkas@localhost)
	by netcore.fi (8.13.8/8.13.8/Submit) with ESMTP id m8OBKmb9032046
	for <netdev@vger.kernel.org>; Wed, 24 Sep 2008 14:20:48 +0300
In-Reply-To: <alpine.LRH.2.00.0809241326070.30892@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Sep 2008, Pekka Savola wrote:
> [psavola@lapps ~]$ more /proc/net/igmp
> Idx	Device    : Count Querier	Group    Users Timer	Reporter
> 1	lo        :     0      V3
> 				010000E0     1 0:00000000		0
> 2	eth0      :     2      V3
> 				010000E0     1 0:00000000		0
> 3	wmaster0  :     3      V3
> 				010000E0     1 0:00000000		0
> 4	wlan0     :     3      V3
> 				 010000E0     1 0:00000000		0
>
> (The header and the fields seem to be a little off in the output..)
>
> [psavola@lapps ~]$ netstat -gn | grep eth0
> eth0            1      224.0.0.1
> eth0            1      ff02::1

Another observation here:  the "Count" field appears to correspond to 
'netstat -gn | wc -l' output.  But this includes both IPv4 and IPv6 
groups.  Is this intentional?  Shouldn't this only count the v4 
entries, just like /proc/net/igmp6 only includes v6 entries?

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
