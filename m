From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2] netfilter: avoid double seq_adjust for loopback
Date: Thu, 16 Jun 2011 17:30:16 +0200
Message-ID: <4DFA2188.5000505@trash.net>
References: <alpine.LFD.2.00.1106080926320.1457@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1106080926320.1457@ja.ssi.bg>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08.06.2011 08:31, Julian Anastasov wrote:
> 	Avoid double seq adjustment for loopback traffic
> because it causes silent repetition of TCP data. One
> example is passive FTP with DNAT rule and difference in the
> length of IP addresses.
> 
> 	This patch adds check if packet is sent and
> received via loopback device. As the same conntrack is
> used both for outgoing and incoming direction, we restrict
> seq adjustment to happen only in POSTROUTING.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied, thanks Julian.
