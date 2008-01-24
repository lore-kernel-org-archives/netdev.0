From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/5] netns netfilter: per-netns IPv6 FILTER, MANGLE, RAW
Date: Thu, 24 Jan 2008 18:40:41 +0100
Message-ID: <4798CD99.1070608@trash.net>
References: <20080124122748.GB27337@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	devel@openvz.org
To: Alexey Dobriyan <adobriyan@sw.ru>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080124122748.GB27337@localhost.sw.ru>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> Now it's possible to list and manipulate per-netns ip6tables rules.
> Filtering decisions are based on init_net's table so far.
> 
> P.S.: remove init_net check in inet6_create() to see the effect


OK, this patch fixes all but one checkpatch warning again.
Please try to make each patch checkpatch-clean next time
since that causes unnecessary work. Thanks (and applied).
