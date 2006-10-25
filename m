From: "Injong Rhee" <rhee@eos.ncsu.edu>
Subject: Re: TCP congestion graphs
Date: Wed, 25 Oct 2006 18:34:17 -0400
Message-ID: <000701c6f885$b57aa390$4a580e98@ncsu2cc0c3fa00>
References: <20061025110207.78d38779@freekitty>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="ISO-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from uni07mr.unity.ncsu.edu ([152.1.224.166]:30868 "EHLO
	uni07mr.unity.ncsu.edu") by vger.kernel.org with ESMTP
	id S965241AbWJYWep (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 18:34:45 -0400
To: "Stephen Hemminger" <shemminger@osdl.org>,
	"Sangtae Ha" <sha2@ncsu.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Not sure why the slow start for cubic is slower than the others.
We will check on this.

----- Original Message ----- 
From: "Stephen Hemminger" <shemminger@osdl.org>
To: "Douglas Leith" <doug.leith@nuim.ie>; "Sangtae Ha" <sha2@ncsu.edu>
Cc: <netdev@vger.kernel.org>
Sent: Wednesday, October 25, 2006 2:02 PM
Subject: TCP congestion graphs


>I ran some congestion window tests against 2.6.19-rc3.
> For congestion window graphs see:
> http://developer.osdl.org/shemminger/tcp/2.6.19-rc3/
> 
> The connection was a single flow with a 500ms RTT and a 
> 100Mbit slowest link speed.
> 
> BIC  OK
> CUBIC OK (after patch)
> HIGHSPEED BROKEN?
> HTCP OK
> RENO OK (massive overshoot)
> SCALEABLE OK
> VEGAS OK (no better than Reno)
> VENO Same as Reno?
> WESTWOOD Overshoot then low window
> 
> Highspeed has something wrong (test glitch?)
> Westwood behaves poorly
> Veno seems no better than either Reno or Vegas in this
> case.
> 
> The end systems were from latest git. The netem bridge is using
> 2.6.18-rt with a patch to netem to use hrtimers.  iperf was modified
> to allow easy selection of congestion control.
> 
> -- 
> Stephen Hemminger <shemminger@osdl.org>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
