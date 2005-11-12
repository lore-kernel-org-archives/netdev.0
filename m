From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] [NETFILTER]: Allow SYN+PSH as valid flag combination
Date: Sat, 12 Nov 2005 12:14:45 -0800 (PST)
Message-ID: <20051112.121445.50339329.davem@davemloft.net>
References: <4374A369.6020308@trash.net>
	<20051111.114801.112784817.davem@davemloft.net>
	<20051112103918.GG10584@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	vlad@storewiz.com, kaber@trash.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: laforge@netfilter.org
In-Reply-To: <20051112103918.GG10584@sunbeam.de.gnumonks.org>
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

From: Harald Welte <laforge@netfilter.org>
Date: Sat, 12 Nov 2005 11:39:18 +0100

> [NETFILTER] {ip,nf}_conntrack TCP: Accept SYN+PUSH like SYN
> 
> Some devices (e.g. Qlogic iSCSI HBA hardware like QLA4010 up to firmware
> 3.0.0.4) initiates TCP with SYN and PUSH flags set.
> 
> The Linux TCP/IP stack deals fine with that, but the connection tracking
> code doesn't.
> 
> This patch alters TCP connection tracking to accept SYN+PUSH as a valid
> flag combination.
> 
> Signed-off-by: Vlad Drukker <vlad@storewiz.com>
> Signed-off-by: Harald Welte <laforge@netfilter.org>

Applied.

I think this one is a -stable candidate (sans the nf_conntrack
bits of course :-).  But that's up to you.
