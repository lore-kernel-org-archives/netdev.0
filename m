From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: filter: dont block softirqs in sk_run_filter()
Date: Tue, 18 Jan 2011 21:33:32 -0800 (PST)
Message-ID: <20110118.213332.191380160.davem@davemloft.net>
References: <1295368755-20931-1-git-send-email-ian.molton@collabora.co.uk>
	<1295371361.3290.15.camel@edumazet-laptop>
	<1295372812.3290.35.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com, xemul@openvz.org, davidel@xmailserver.org,
	alban.crequy@collabora.co.uk, ian.molton@collabora.co.uk
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295372812.3290.35.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 18 Jan 2011 18:46:52 +0100

> Packet filter (BPF) doesnt need to disable softirqs, being fully
> re-entrant and lock-less.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
