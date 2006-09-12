From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: TCP Pacing
Date: Wed, 13 Sep 2006 09:26:19 +1200
Message-ID: <5640c7e00609121426t75f5519at562a85f40b64163@mail.gmail.com>
References: <200609121958.22820.root@danielinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Stephen Hemminger" <shemminger@osdl.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	"Carlo Caini" <ccaini@deis.unibo.it>,
	"Rosario Firrincieli" <rfirrincieli@arces.unibo.it>,
	"Giovanni Pau" <gpau@cs.ucla.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-f131.google.com ([64.233.182.131]:26498 "EHLO
	nf-out-f131.google.com") by vger.kernel.org with ESMTP
	id S1030270AbWILV0V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Sep 2006 17:26:21 -0400
Received: by nf-out-f131.google.com with SMTP id k65so204231nfa
        for <netdev@vger.kernel.org>; Tue, 12 Sep 2006 14:26:20 -0700 (PDT)
To: root@danielinux.net
In-Reply-To: <200609121958.22820.root@danielinux.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/13/06, Daniele Lacamera <root@danielinux.net> wrote:
> Hello,
>
> Please let me insist once again on the importance of adding a TCP Pacing
> mechanism in our TCP, as many people are including this algorithm in
> their congestion control proposals. Recent researches have found out
> that it really can help improving performance in different scenarios,
> like satellites and long-delay high-speed channels (>100ms RTT, Gbit).
> Hybla module itself is cripple without this feature in its natural
> scenario.

Where is the published research? If you are going to mention research
you need URLs to papers and please put this in source code too so
people can check.
>
> The following patch is totally non-invasive: it has a config option and
> a sysctl switch, both turned off by default. When the config option is
> enabled, it adds only 6B to the tcp_sock.
>
I agree with Arnaldo's comments and also would add I don't like having
to select 1000 as HZ unit. Something is wrong if you need this as I
can run higher resolution timers without having to do this....

Haven't reviewed the rest of the code or tested.

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
