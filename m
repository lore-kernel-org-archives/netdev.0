From: Jon Zhou <Jon.Zhou@jdsu.com>
Subject: MSI-X resource become less and less
Date: Wed, 26 May 2010 01:38:49 -0700
Message-ID: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2498091D15@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og127.obsmtp.com ([64.18.2.210]:49833 "HELO
	exprod7og127.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751654Ab0EZIjh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 04:39:37 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

let's take Broadcom bnx2x as example:

first of all I can insmod bnx2x.ko multi_mode=1 num_queue=16
but when I do this:
rmmod bnx2x; insmod bnx2x.ko multi_mode=1 num_queue=8   ->OK 8 queues
rmmod bnx2x; insmod bnx2x.ko multi_mode=1 num_queue=4   ->OK 4 queues

...
finally I do this:
rmmod bnx2x; insmod bnx2x.ko multi_mode=1 num_queue=4

I found the driver can only get 1 or 2 queues! it doesn't come back to 4+ queues any longer!

MSI-X resource become less and less, any resource isn't free?

kernel:2.6.27.19
XEON 5500 16 core

thanks
jon

