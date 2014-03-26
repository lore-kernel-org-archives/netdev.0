From: "H. Peter Anvin" <hpa@linux.intel.com>
Subject: Re: [PATCH net-next v2 8/9] net: filter: rework/optimize internal
 BPF interpreter's instruction set
Date: Tue, 25 Mar 2014 17:24:27 -0700
Message-ID: <53321E3B.8080709@linux.intel.com>
References: <1395749457-16178-1-git-send-email-dborkman@redhat.com>	<1395749457-16178-9-git-send-email-dborkman@redhat.com> <20140325.201712.1651156258234145348.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org, hagen@jauu.net,
	keescook@chromium.org, pmoore@redhat.com, mingo@kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, dborkman@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140325.201712.1651156258234145348.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/25/2014 05:17 PM, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Tue, 25 Mar 2014 13:10:56 +0100
> 
>>   - Conditional jt/jf targets replaced with jt/fall-through,
>>     and forward/backward jumps now possible as well
> 
> Ummm... does anyone even remember why backwards jumps were not allowed
> in the original BPF?
> 
> It's to guarentee forward progress in the filter.
> 
> Allowing branching backward would allow endless loops.
> 
> Please remove this feature.
> 

If you allow loops, it greatly increases the expressibility of the
language, but we would really need another control to limit CPU usage.

	-hpa
