From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: network stream fairness
Date: Mon, 09 Nov 2015 09:23:02 -0800
Message-ID: <1447089782.17135.48.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5640BEAC.10404@axis.com>
	 <1447084258.17135.39.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5640C15E.805@axis.com>
	 <1447085271.17135.44.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1447086271.17135.45.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5640CED5.6040103@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "edumazet@google.com" <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Niklas Cassel <niklas.cassel@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33704 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751872AbbKIRXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 12:23:05 -0500
Received: by pabfh17 with SMTP id fh17so205160322pab.0
        for <netdev@vger.kernel.org>; Mon, 09 Nov 2015 09:23:04 -0800 (PST)
In-Reply-To: <5640CED5.6040103@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-11-09 at 17:50 +0100, Niklas Cassel wrote:

> 
> for i in `seq 1 20`; do ss -temoi dst 192.168.0.141; sleep 1; done
...
> ESTAB      0      0                                192.168.0.1:54578                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901838 sk:ffff880143735040
> State      Recv-Q Send-Q                         Local Address:Port                             Peer Address:Port   
> ESTAB      0      0                                192.168.0.1:54576                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901837 sk:ffff880143735800
> ESTAB      0      0                                192.168.0.1:54574                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 qack:10 uid:20283 ino:7902591 sk:ffff880223311800
> ESTAB      1448   0                                192.168.0.1:54578                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901838 sk:ffff880143735040

This is the receiver, I would like to see the sender side, since the
changes we talk about are at his side, of course.

Thanks.
