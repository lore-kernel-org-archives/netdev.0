From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/5] netns netfilter: per-netns xt_tables
Date: Tue, 22 Jan 2008 17:51:45 +0100
Message-ID: <47961F21.3000302@trash.net>
References: <20080121145252.GG27615@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	devel@openvz.org
To: Alexey Dobriyan <adobriyan@sw.ru>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080121145252.GG27615@localhost.sw.ru>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> In fact all we want is per-netns set of rules, however doing that will
> unnecessary complicate routines such as ipt_hook()/ipt_do_table, so
> make full xt_table array per-netns.
> 
> Every user stubbed with init_net for a while.


Applied.

