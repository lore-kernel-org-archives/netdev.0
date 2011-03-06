From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH 1/2] Issue NETDEV_CHANGE notification when bridge changes
 state
Date: Sun, 06 Mar 2011 19:01:40 +0100
Message-ID: <4D73CC04.6060909@computer.org>
References: <20110306051833.GA3098@mira.lan.galacticasoftware.com> <1154832100.13939.1299393783798.JavaMail.root@tahiti.vyatta.com> <20110306080328.GA3850@mira.lan.galacticasoftware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Adam Majer <adamm@zombino.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay001.isp.belgacom.be ([195.238.6.51]:50606 "EHLO
	mailrelay001.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753649Ab1CFSCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2011 13:02:39 -0500
In-Reply-To: <20110306080328.GA3850@mira.lan.galacticasoftware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/11 09:03, Adam Majer wrote:
> On Sat, Mar 05, 2011 at 10:43:03PM -0800, Stephen Hemminger wrote:
>> Why not set forwarding delay to zero? I don't think you are using STP?
 >
> No, I'm not relying on STP. I think setting learning->forwarding delay
> to 0 could cause problems with STP like loops until the loop is
> detected.

I don't think that Stephen is saying that you should hard-code the 
forwarding delay as zero (i.e. to remove the delay from the kernel 
completely), but rather use brctl to set the forwarding delay to zero on 
bridge instances in which you're not using STP.

HTH, Jan

