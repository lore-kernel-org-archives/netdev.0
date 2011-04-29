From: zhou rui <zhourui.cn@gmail.com>
Subject: same application has different performance with kernel 2.6.32/34/36
Date: Fri, 29 Apr 2011 22:46:04 +0800
Message-ID: <BANLkTinF8Mfs+pqfGV0bLqm_3VyKCMn0LA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: jon.zhou@jdsu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:36453 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755632Ab1D2OqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 10:46:06 -0400
Received: by iwn34 with SMTP id 34so3124785iwn.19
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2011 07:46:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi
my test application add a packet hook via  dev_add_pack(&prot_hook);
then copy the packet to a shared memory between userspace and kernel

tests wereperformed at same machine(DL380 G7, 12cores, intel X520 10G
nic),same traffic,same nic driver(ixgbe 3.3.9)

kernel 2.6.32.12 (SUSE SLES11,SP1)
APPlication cpu usage: 5-6%


kernel updated to  2.6.34.7
APPlication cpu usage: 19-25%

kernel 2.6.36.4 (enable/disable RPS)
APPlication cpu usage 35-40%


before I installing profile tool to find the root cause, any idea about it?
'top' result is not accurate  in older kernel? or any kernel
module/feature impact this?
