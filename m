From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: pppoe, /proc/net/pppoe wrong (extra entries)
Date: Tue, 29 Jan 2008 16:36:39 +0200
Message-ID: <20080129141750.M30548@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: paulus@samba.org, mostrows@speakeasy.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:45157 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763125AbYA2OhB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 09:37:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi again

I notice strange thing, with /proc/net/pppoe, not sure if it is bug, but for 
me it looks wrong.

cat /proc/net/pppoe
there is normal entries of users, but at the end i have 
....
00000D00 00:16:D3:0B:F9:34     eth1
00004000 00:50:22:00:1C:FC     eth1
00007E00 00:03:47:BD:34:25     eth1
00007E00 00:03:47:BD:34:25     eth1
00007E00 00:03:47:BD:34:25     eth1
00007E00 00:03:47:BD:34:25     eth1
00007E00 00:03:47:BD:34:25     eth1
....
and last entry duplicates till end.

i have script to get customers interfaces, so i am using it to calculate 
amount of users logged in

defaulthost ~ #cat /proc/net/pppoe |grep -i '00:03:47:BD:34:25'|wc -l
40
defaulthost ~ #cat /proc/net/pppoe |wc -l
113
defaulthost ~ #pppctrl |wc -l
73

It means there is 40 extra entries. 00:03:47:BD:34:25 host have established, 
but only one session. I am seeing similar issue on all remaining pppoe 
servers, extra entries with same mac at the end.

If you need more info or access, please let me know.

--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

