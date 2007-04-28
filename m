From: Vincent ETIENNE <ve@vetienne.net>
Subject: Re: [PROBLEM] Bonding driver in linux-2.6.21-rc6-mm1
Date: Sat, 28 Apr 2007 22:37:42 +0200
Message-ID: <200704282237.42753.ve@vetienne.net>
References: <200704262058.33087.ve@vetienne.net> <200704272205.29131.ve@vetienne.net> <20070427153237.03f3b59c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.vetienne.net ([87.98.219.23]:3610 "EHLO
	mail1.vetienne.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754757AbXD1Uqv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2007 16:46:51 -0400
In-Reply-To: <20070427153237.03f3b59c.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le Saturday 28 April 2007 00:32:37 Andrew Morton, vous avez =E9crit=A0:
> On Fri, 27 Apr 2007 22:05:28 +0200
>

> because we thought we'd fixed the rtnl_lock() problems in 2.6.21-rc7-=
mm2.
> Are you sure that log is from 2.6.21-rc7-mm2?


Yes. I have retested it another time ( for adding the small usb debug=20
message ) and get the same message a new time.

Maybe a tiny difference : only eth0 was setup during boot ( bond0 and e=
th1 was=20
not setup - volontary  - to avoid problem that could interfere with usb=
 ).=20
Ony after having done my usb test, i have stopped the eth0, setup bond=20
interface and restart bond interface and got the same problem with the =
same=20
back trace.

Is there anything i can do to get you more precise information ?




