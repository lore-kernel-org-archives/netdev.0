From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [Patch v2] skbuff: Hide GFP_ATOMIC page allocation failures for
 dropped packets
Date: Mon, 27 May 2013 21:56:00 +0400
Message-ID: <51A39E30.5030708@cogentembedded.com>
References: <1369599557-22677-1-git-send-email-atomlin@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	pshelar@nicira.com, mst@redhat.com, alexander.h.duyck@intel.com,
	riel@redhat.com, aquini@redhat.com, linux-kernel@vger.kernel.org
To: atomlin@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369599557-22677-1-git-send-email-atomlin@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 27-05-2013 0:19, atomlin@redhat.com wrote:

> From: Aaron Tomlin <atomlin@redhat.com>

> Since v1:
>   - Removed unnecessary parentheses

    The "changes since version X" section should typically go after --- 
tearline, else the mainatiner will have to edit your patch before applying.

> ---8<---

> Failed GFP_ATOMIC allocations by the network stack result in dropped
> packets, which will be received on a subsequent retransmit, and an
> unnecessary, noisy warning with a kernel backtrace.

> These warnings are harmless, but they still cause users to panic and
> file bug reports over dropped packets. It would be better to hide the
> failed allocation warnings and backtraces, and let retransmits handle
> dropped packets quietly.

> Signed-off-by: Aaron Tomlin <atomlin@redhat.com>

WBR, Sergei
