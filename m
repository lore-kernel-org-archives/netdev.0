From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.17 kernel crash while loading IPoIB
Date: Tue, 23 Sep 2014 02:05:38 -0700
Message-ID: <1411463138.26859.168.camel@edumazet-glaptop2.roam.corp.google.com>
References: <637AD4DF2E595346BAB0DF8C46F3A2B003291F06@BGSMSX101.gar.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Sharma, Karun" <karun.sharma@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:38212 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753133AbaIWJFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 05:05:39 -0400
In-Reply-To: <637AD4DF2E595346BAB0DF8C46F3A2B003291F06@BGSMSX101.gar.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-23 at 05:15 +0000, Sharma, Karun wrote:
> Hello:
> 
> I am facing an issue wherein kernel 3.17 crashes while loading IPoIB
> module. I guess the issue discussed in this thread
> (https://www.mail-archive.com/linux-rdma@vger.kernel.org/msg20963.html) is similar.
> 
> We were able to reproduce the issue with RC6 also. Here are the steps
> I followed:
> 
> I compiled and installed 3.17 kernel on top of RHEL 6.5. 
> Then I changed rdma.conf to not load IPoIB (If I don't do this, the
> kernel crashes while booting and starting RDMA service.)
> After the server comes up, I just did "modprobe ib_ipoib" and kernel
> crashes.
> Please see below the kernel back trace.
> 
> Seeing the announcement, it looks like RC6 will be the last RC for
> 3.17 kernel. Will the release happen with this issue? Is there any
> workaround available for this issue?
> I am not sure what mechanism/process is used to report issue to kernel
> community.
> 
> Regards
> Karun

This seems fixed now :

http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=257117862634d89de33fec74858b1a0ba5ab444b

http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=b49fe36208b45f76dfbcfcd3afd952a33fa9f5ce
