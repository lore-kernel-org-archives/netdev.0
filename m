From: "David S. Miller" <davem@davemloft.net>
Subject: Re: ipsec hang
Date: Tue, 23 Nov 2004 18:46:02 -0800
Message-ID: <20041123184602.48029039.davem@davemloft.net>
References: <200411240134.50314@senat>
	<41A3E4B4.8080401@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mg@iceni.pl, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261706AbUKXCuQ@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41A3E4B4.8080401@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 24 Nov 2004 02:32:36 +0100
Patrick McHardy <kaber@trash.net> wrote:

> This patch should fix it. The patch "Fix policy update bug when increasing
> priority of last policy" broke this, when a policy with lower priority than
> an existing policy is inserted xfrm_policy_insert loops forever.

Good catch Patrick, patch applied.

Thanks.
