From: "Francesco Saverio Giudice" <info@fsgiudice.com>
Subject: Error on ip route replace command
Date: Fri, 22 Feb 2008 23:22:01 +0100
Message-ID: <00a701c875a1$58f70fb0$b400a8c0@ASUSFSG>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host18-125-static.189-82-b.business.telecomitalia.it ([82.189.125.18]:53338
	"EHLO mailserver.infocomsrl.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754587AbYBVW2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2008 17:28:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

I have a problem with kernel 2.6.24.

Having a running configuration using Shorewall and restarting it I got 
follow error:
RTNETLINK answers: File exists

Tom Eastep, Shorewall creator, told me to inform you about the problem.

Here is the mail:
------------------------------------------------------------
Francesco Saverio Giudice wrote:
> Hi Tom,
>
> I get the error:
>
> ---------
> # ip route add 1.2.4.5 dev eth3
> # ip route replace 1.2.4.5 dev eth3
> RTNETLINK answers: File exists
> ---------
>
> I have to patch kernel or something else ?
>

You should report it at netdev@vger.kernel.org (that's where the Linux
networking developers hang out). This failure does not occur with kernel
2.6.22 and iproute2 ss070710:

gateway:~ # ip route add 1.2.4.5 dev eth0
gateway:~ # ip route replace 1.2.4.5 dev eth0
gateway:~ # ip route del 1.2.4.5

-Tom
-- 
Tom Eastep    \ Nothing is foolproof to a sufficiently talented fool
Shoreline,     \ http://shorewall.net
Washington USA  \ teastep@shorewall.net
PGP Public Key   \ https://lists.shorewall.net/teastep.pgp.key

------------------------------------------------------------

Best Regards

Francesco Saverio Giudice



