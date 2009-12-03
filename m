From: Patrick McHardy <kaber@trash.net>
Subject: Re: match SIP & RTP packets
Date: Thu, 03 Dec 2009 12:11:20 +0100
Message-ID: <4B179CD8.2080002@trash.net>
References: <4B16EC4F.4080703@forinicom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter@vger.kernel.org, netdev@vger.kernel.org
To: Lorenzo Allegrucci <lorenzo.allegrucci@forinicom.it>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <4B16EC4F.4080703@forinicom.it>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lorenzo Allegrucci wrote:
> 
> Hi all, it's not clear to me whether nf_conntrack_sip does SIP and RTP
> connection
> tracking or just SIP.. can you clarify?
> I need to match both SIP and RTP packets and I was wondering if the rule
> below would satisfy my requirements:
> 
> iptables -t mangle -A FORWARD -o eth0 -m helper --helper sip -j CLASSIFY
> --set-class 1:1

Almost, this will match on RTP packets and incoming signalling
connections (-m helper matches on expected connections). What's
missing is the original signalling connection on port 5060.
