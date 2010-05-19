From: Jon Zhou <Jon.Zhou@jdsu.com>
Subject: any change in socket systemcall or packet_mmap regarding multiqueue
 nic?
Date: Tue, 18 May 2010 19:55:54 -0700
Message-ID: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497EFC786@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og110.obsmtp.com ([64.18.2.173]:60584 "HELO
	exprod7og110.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753683Ab0ESDCo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 23:02:44 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi
the multiqueue networking can utilize multi-core to process packets from multiqueue nic,
but any change in related userspace application part, such as socket system call, packet_mmap? these userspace API can also utilize multicore to process packets from kernel?
otherwise they have to read data in serialization

thanks
jon 
