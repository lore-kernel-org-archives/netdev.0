From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: same application has different performance with kernel
 2.6.32/34/36
Date: Fri, 29 Apr 2011 08:48:48 -0700
Message-ID: <20110429084848.64a48efa@nehalam>
References: <BANLkTinF8Mfs+pqfGV0bLqm_3VyKCMn0LA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jon.zhou@jdsu.com
To: zhou rui <zhourui.cn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36168 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751969Ab1D2Psv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Apr 2011 11:48:51 -0400
In-Reply-To: <BANLkTinF8Mfs+pqfGV0bLqm_3VyKCMn0LA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Apr 2011 22:46:04 +0800
zhou rui <zhourui.cn@gmail.com> wrote:

> hi
> my test application add a packet hook via  dev_add_pack(&prot_hook);
> then copy the packet to a shared memory between userspace and kernel
> 
> tests wereperformed at same machine(DL380 G7, 12cores, intel X520 10G
> nic),same traffic,same nic driver(ixgbe 3.3.9)
> 
> kernel 2.6.32.12 (SUSE SLES11,SP1)
> APPlication cpu usage: 5-6%
> 
> 
> kernel updated to  2.6.34.7
> APPlication cpu usage: 19-25%
> 
> kernel 2.6.36.4 (enable/disable RPS)
> APPlication cpu usage 35-40%
> 
> 
> before I installing profile tool to find the root cause, any idea about it?
> 'top' result is not accurate  in older kernel? or any kernel
> module/feature impact this?

The report is appreciated, but since your application is not part of the main
kernel, developers are going to be unable to provide much direct help.
If it is closed source, go away we won't help with closed kernel components.
If it is open source, post a link where people can download it.

This is the kind of problem that requires effort and running multiple
times and using kernel bisection can show which change had the most impact.
It could be driver, scheduling or the change to packet steering.

