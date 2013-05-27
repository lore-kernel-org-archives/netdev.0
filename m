From: Rik van Riel <riel@redhat.com>
Subject: Re: [Patch v2] skbuff: Hide GFP_ATOMIC page allocation failures for
 dropped packets
Date: Mon, 27 May 2013 13:39:11 -0400
Message-ID: <51A39A3F.8080903@redhat.com>
References: <1369599557-22677-1-git-send-email-atomlin@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	pshelar@nicira.com, mst@redhat.com, alexander.h.duyck@intel.com,
	aquini@redhat.com, sergei.shtylyov@cogentembedded.com,
	linux-kernel@vger.kernel.org
To: atomlin@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369599557-22677-1-git-send-email-atomlin@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/26/2013 04:19 PM, atomlin@redhat.com wrote:
> From: Aaron Tomlin <atomlin@redhat.com>
>
> Since v1:
>   - Removed unnecessary parentheses
>
> ---8<---
>
> Failed GFP_ATOMIC allocations by the network stack result in dropped
> packets, which will be received on a subsequent retransmit, and an
> unnecessary, noisy warning with a kernel backtrace.
>
> These warnings are harmless, but they still cause users to panic and
> file bug reports over dropped packets. It would be better to hide the
> failed allocation warnings and backtraces, and let retransmits handle
> dropped packets quietly.

Yes please. Getting memory management bug reports for
dropped network packets got old years ago.  Lets get
rid of those messages.

> Signed-off-by: Aaron Tomlin <atomlin@redhat.com>

Reviewed-by: Rik van Riel <riel@redhat.com>
