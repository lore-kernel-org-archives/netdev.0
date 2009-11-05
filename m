From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: nf_nat_helper: tidy up adjust_tcp_sequence
Date: Thu, 05 Nov 2009 15:53:31 +0100
Message-ID: <4AF2E6EB.9000304@trash.net>
References: <20090922155911.20008.96214.stgit@jazzy.zrh.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Hannes Eder <heder@google.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090922155911.20008.96214.stgit@jazzy.zrh.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hannes Eder wrote:
> The variable 'other_way' gets initialized but is not read afterwards,
> so remove it.  Pass the right arguments to a pr_debug call.
> 
> While being at tidy up a bit and it fix this checkpatch warning:
>   WARNING: suspect code indent for conditional statements
> 
> Signed-off-by: Hannes Eder <heder@google.com>
> 

Applied with some minor changes (use enum ip_conntrack_dir instead
of int, use function name literally instead of "%s()" with __func__).
