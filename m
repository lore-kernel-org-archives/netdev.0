From: Patrick McHardy <kaber@trash.net>
Subject: Re: Missing csum_fold() in ip6t_HL.c ?
Date: Mon, 12 Feb 2007 15:52:13 +0100
Message-ID: <45D07F1D.7030202@trash.net>
References: <20060915103755.GB5286@martell.zuzino.mipt.ru>
	<20070212.234721.90984848.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	adobriyan@gmail.com
To: yoshfuji@linux-ipv6.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
In-Reply-To: <20070212.234721.90984848.yoshfuji@linux-ipv6.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / $B5HF#1QL@ wrote:
> In article <20060915103755.GB5286@martell.zuzino.mipt.ru> (at Fri, 15 Sep 2006 14:37:56 +0400), Alexey Dobriyan <adobriyan@gmail.com> says:
> 
> 
>>It looks like "diffs" array is write-only. It also looks like ipv4
>>occurences use some csum_fold() trickery. Was is forgotten here? Should
>>"diffs" be removed?
> 
> 
> Since we do not have checksum in IPv6 header, we do not need to
> adjust checksum when we touch hoplimit.
> 
> So, just removing it should be safe.


This already is taken care of. I noticed our listmaster didn't
approve any held messages for a couple of month and am currently
going through the backlog (Alexey's mail is quite old).
