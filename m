From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: merge of the wireless-next tree into the net-next
 tree
Date: Tue, 03 Jan 2012 20:27:33 -0500 (EST)
Message-ID: <20120103.202733.1070369898271428121.davem@davemloft.net>
References: <20120104105947.8bac77d1d7198a49e6feeca8@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, kvalo@qca.qualcomm.com,
	linville@tuxdriver.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120104105947.8bac77d1d7198a49e6feeca8@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 4 Jan 2012 10:59:47 +1100

> I noticed that the wireless-next tree has been merged into the net-next
> tree today.  Has anything been done about the build failure I reported in
> the wireless-next a while ago:
> 
> On 12/22/2011 16:58 +1100, Stephen Rothwell wrote:
>>
>> After merging the final tree, today's linux-next build (powerpc
>> allyesconfig) failed like this:
>> 
>> drivers/net/wireless/ath/ath6kl/cfg80211.c:27:1: error: expected ')' before 'KBUILD_MODNAME'
>> drivers/net/wireless/ath/ath6kl/cfg80211.c:27:1: error: 'KBUILD_MODNAME' undeclared here (not in a function)
>> drivers/net/wireless/ath/ath6kl/cfg80211.c:27:1: error: expected ',' or ';' before string constant

It happens on any platform not just powerpc, John please fix this and
don't have known unresolved -next build failures in your tree when you
push to me.
