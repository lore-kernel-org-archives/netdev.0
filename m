From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2.33] datapath: Add basic MPLS support to kernel
Date: Thu, 20 Jun 2013 12:28:32 -0700
Message-ID: <CAEP_g=8X-vdMQ7RngJyidKsxhaS_p6Pa8JVh3U+fD64rt2Umzg@mail.gmail.com>
References: <1371539209-31134-1-git-send-email-horms@verge.net.au> <20130620005653.GA21614@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jarno Rajahalme <jarno.rajahalme@nsn.com>,
	Joe Stringer <joe@wand.net.nz>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog115.obsmtp.com ([74.125.149.238]:46641 "HELO
	na3sys009aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S965665Ab3FTT2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 15:28:53 -0400
Received: by mail-ie0-f175.google.com with SMTP id a13so17280858iee.20
        for <netdev@vger.kernel.org>; Thu, 20 Jun 2013 12:28:52 -0700 (PDT)
In-Reply-To: <20130620005653.GA21614@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 19, 2013 at 5:56 PM, Simon Horman <horms@verge.net.au> wrote:
> On Tue, Jun 18, 2013 at 04:06:49PM +0900, Simon Horman wrote:
>> Allow datapath to recognize and extract MPLS labels into flow keys
>> and execute actions which push, pop, and set labels on packets.
>>
>> Based heavily on work by Leo Alterman, Ravi K, Isaku Yamahata and Joe Stringer.
>>
>> Cc: Ravi K <rkerur@gmail.com>
>> Cc: Leo Alterman <lalterman@nicira.com>
>> Cc: Isaku Yamahata <yamahata@valinux.co.jp>
>> Cc: Joe Stringer <joe@wand.net.nz>
>> Signed-off-by: Simon Horman <horms@verge.net.au>
>>
>> ---
>>
>> This patch depends on "gre: Restructure tunneling" which it aims
>> to be compatible with.
>
> To clarify. The dependency relates to a conflict when applying this patch
> which modifies datapath/linux/compat/gso.[ch], files that are
> created by "gre: Restructure tunneling". I believe it would
> be trivial to reverse the dependency so that this patch creates
> those files and "gre: Restructure tunneling" applies on top of it
> as the two patches add different functions to those files.
>
> As such I think it would be better to describe this patch
> as compatible with "gre: Restructure tunneling" rather than
> dependent on it.

I agree that's the case. However, now that the OVS GRE code is
upstream, I think I can take just a quick pass over the GRE patch to
get it in and then we won't have any dependency issues.
