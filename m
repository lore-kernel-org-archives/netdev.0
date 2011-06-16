From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: fix looped (broad|multi)cast's MAC handling.
Date: Thu, 16 Jun 2011 17:27:58 +0200
Message-ID: <4DFA20FE.80708@trash.net>
References: <4DF0EFE6.4010206@trash.net> <1307690440-18760-1-git-send-email-cavallar@lri.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, Nicolas Cavallari <cavallar@lri.fr>
To: Nicolas Cavallari <Nicolas.Cavallari@lri.fr>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1307690440-18760-1-git-send-email-cavallar@lri.fr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10.06.2011 09:20, Nicolas Cavallari wrote:
> By default, when broadcast or multicast packet are sent from a local
> application, they are sent to the interface then looped by the kernel
> to other local applications, going throught netfilter hooks in the process.
> 
> These looped packet have their MAC header removed from the skb by the kernel
> looping code.
> This confuse various netfilter's netlink queue, netlink log and the
> legacy ip_queue, because they try to extract a hardware
> address from these packets, but extracts a part of the IP header instead.
> 
> This patch prevent NFQUEUE, NFLOG and ip_QUEUE to include a MAC header
> if there is none in the packet.

Applied, thanks Nicolas.
