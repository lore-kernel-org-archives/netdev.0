From: "Quan Sun" <cfk.quan@gmail.com>
Subject: Re: Slow tcp handshakes rate of 2.6.20 and 2.6.19
Date: Sun, 29 Apr 2007 15:27:49 +0800
Message-ID: <e810d8480704290027s3d54c087j774ad666443cbc5e@mail.gmail.com>
References: <e810d8480704271935l3a597d89g260bcb185c457937@mail.gmail.com>
	 <7e63f56c0704272143s677cdad8rcf64d1e97d88fc40@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Robert Iakobashvili" <coroberti@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.234]:43942 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756261AbXD2H1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2007 03:27:50 -0400
Received: by nz-out-0506.google.com with SMTP id o1so1616782nzf
        for <netdev@vger.kernel.org>; Sun, 29 Apr 2007 00:27:49 -0700 (PDT)
In-Reply-To: <7e63f56c0704272143s677cdad8rcf64d1e97d88fc40@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
On 4/28/07, Robert Iakobashvili <coroberti@gmail.com> wrote:
> What are the
> #cat /proc/sys/net/ipv4/tcp_mem values for your kernels?
>
> Do you see tcp memory pressure by
> #netstat -s ?
>

In my original kernel (2.6.20.6),  tcp_mem is
 24576, 32768, 49152
There is several memory_pressure in the `netstat -s`.

After patching
author  John Heffner <jheffner@psc.edu>
        Fri, 16 Mar 2007 22:04:03 +0000 (15:04 -0700)
commit  53cdcc04c1e85d4e423b2822b66149b6f2e52c2c
[TCP]: Fix tcp_mem[] initialization.

In 2.6.20.6-patched, tcp_mem is
97440, 129920, 194880
And during my benchmark, 'memory_pressure' is always 0.

After these two days test, this patch works fine for me and benchmark
gets a good result(as good as 2.6.18).

Thank you very much for your help.
-- 
Quan Sun
