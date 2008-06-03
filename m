From: Bernhard Miklautz <miklautz@inqnet.at>
Subject: Re: Veth problems with bridge
Date: Tue, 03 Jun 2008 17:24:14 +0200
Message-ID: <4845621E.6080104@inqnet.at>
References: <4845475A.7020207@inqnet.at> <48455240.8070102@trash.net>
Reply-To: miklautz@inqnet.at
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <48455240.8070102@trash.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Patrick,

Patrick McHardy wrote:
> Bernhard Miklautz wrote:
>> [...]
>> I also tried the whole setup without using veth; the IP directly bound
>> to br0, as well as without the bridge at all. No problems with that.
>> So there might be some problems with veth?
> 
> Does "echo 0 > /proc/sys/net/bridge/bridge-nf-call-iptables" fix it?

On my hardware machine this seems to fix the problem :). But why does
bridge-nf-call-iptables influent source nat on an other interface? -
Shouldn't the source address always be translated when an output
interface is set (iptables -A POSTROUTING -o eth3 -t nat -j MASQUERADE)?

Thanks for you quick help.

Best regards,
Bernhard


