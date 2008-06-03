From: Patrick McHardy <kaber@trash.net>
Subject: Re: Veth problems with bridge
Date: Tue, 03 Jun 2008 16:16:32 +0200
Message-ID: <48455240.8070102@trash.net>
References: <4845475A.7020207@inqnet.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: miklautz@inqnet.at
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <4845475A.7020207@inqnet.at>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bernhard Miklautz wrote:
> [...]
> I also tried the whole setup without using veth; the IP directly bound
> to br0, as well as without the bridge at all. No problems with that.
> So there might be some problems with veth?

Does "echo 0 > /proc/sys/net/bridge/bridge-nf-call-iptables" fix it?

