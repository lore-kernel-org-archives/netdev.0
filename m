From: Avi Kivity <avi@redhat.com>
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
Date: Mon, 22 Aug 2011 09:36:04 +0300
Message-ID: <4E51F8D4.5070804@redhat.com>
References: <20110601011527.GN19505@random.random>	 <alpine.LSU.2.00.1105312120530.22808@sister.anvils>	 <4DE5DCA8.7070704@fnarfbargle.com> <4DE5E29E.7080009@redhat.com>	 <4DE60669.9050606@fnarfbargle.com> <4DE60918.3010008@redhat.com>	 <4DE60940.1070107@redhat.com> <4DE61A2B.7000008@fnarfbargle.com>	 <20110601111841.GB3956@zip.com.au> <4DE62801.9080804@fnarfbargle.com>	 <20110601230342.GC3956@zip.com.au> <4DE8E3ED.7080004@fnarfbargle.com>	 <4DEB3AE4.8040700@redhat.com>  <4DEB8872.2060801@fnarfbargle.com>	 <1307391746.2642.11.camel@edumazet-laptop>	 <4DEE273F.7090402@fnarfbargle.com> <1307453874.3091.14.camel@edumazet-laptop> <4E4FB3B7.4040501@fnarfbargle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, CaT <cat@zip.com.au>,
	Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org,
	kvm@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Brad Campbell <lists2009@fnarfbargle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751869Ab1HVGg0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Aug 2011 02:36:26 -0400
In-Reply-To: <4E4FB3B7.4040501@fnarfbargle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/20/2011 04:16 PM, Brad Campbell wrote:
> Author: Alexander Duyck <alexander.h.duyck@intel.com>
> Date:   Thu Jul 1 13:28:27 2010 +0000
>
>     x86: Drop CONFIG_MCORE2 check around setting of NET_IP_ALIGN
>
>     This patch removes the CONFIG_MCORE2 check from around 
> NET_IP_ALIGN.  It is
>     based on a suggestion from Andi Kleen.  The assumption is that 
> there are
>     not any x86 cores where unaligned access is really slow, and this 
> change
>     would allow for a performance improvement to still exist on 
> configurations
>     that are not necessarily optimized for Core 2.
>
>     Cc: Andi Kleen <ak@linux.intel.com>
>     Cc: Thomas Gleixner <tglx@linutronix.de>
>     Cc: Ingo Molnar <mingo@redhat.com>
>     Cc: "H. Peter Anvin" <hpa@zytor.com>
>     Cc: x86@kernel.org
>     Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>     Acked-by: H. Peter Anvin <hpa@zytor.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
> :040000 040000 5a15867789080a2f67a74b17c4422f85b7a9fb4a 
> b98769348bd765731ca3ff03b33764257e23226c M    arch
>
> I can confirm this bug exists in the 3.0 kernel, however I'm unable to 
> reproduce it on todays git.
>
> So anyone using netfilter, kvm and bridge on kernels between 
> 2.6.36-rc1 and 3.0 may hit this bug, but it looks like it is fixed in 
> the current 3.1-rc kernels.
>

Thanks for this effort.  I don't think this patch is buggy in itself, it 
merely exposed another bug which was fixed later on.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

