From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: [PATCH] netfilter: Fix br_nf_pre_routing() in
 conjunction with bridge-nf-call-ip(6)tables=0
Date: Thu, 05 Jan 2012 20:50:45 +0100
Message-ID: <4F05FF15.5010809@pandora.be>
References: <4F025A07.2000304@nod.at>
	<1325597164-13459-1-git-send-email-richard@nod.at>
	<1325597164-13459-2-git-send-email-richard@nod.at>
	<20120103081521.2fec3a29@nehalam.linuxnetplumber.net>
	<4F033E11.5060707@nod.at> <4F0361D7.3000602@pandora.be>
	<4F03650D.8050200@nod.at> <4F049290.3090803@pandora.be>
	<4F04DD19.601@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>, davem@davemloft.net
To: Richard Weinberger <richard@nod.at>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <4F04DD19.601@nod.at>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Op 5/01/2012 0:13, Richard Weinberger schreef:
>
> Let's export brnf_call_iptables and brnf_call_ip6tables, such that
> physdev_mt_check() can notify the user that his iptables rule will have
> no effect.
>

I don't want to introduce a runtime dependency between the iptables 
physdev module and the bridge module.
This should keep working:
#modprobe bridge
#modprobe xt_physdev
#rmmod bridge
It will stop working if you use exported symbols of the bridge module in 
the physdev module.

Bart

-- 
Bart De Schuymer
www.artinalgorithms.be
