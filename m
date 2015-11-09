From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: network stream fairness
Date: Mon, 09 Nov 2015 08:24:31 -0800
Message-ID: <1447086271.17135.45.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5640BEAC.10404@axis.com>
	 <1447084258.17135.39.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5640C15E.805@axis.com>
	 <1447085271.17135.44.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "edumazet@google.com" <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Niklas Cassel <niklas.cassel@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34774 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751952AbbKIQYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 11:24:33 -0500
Received: by padhx2 with SMTP id hx2so195211662pad.1
        for <netdev@vger.kernel.org>; Mon, 09 Nov 2015 08:24:33 -0800 (PST)
In-Reply-To: <1447085271.17135.44.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-11-09 at 08:07 -0800, Eric Dumazet wrote:

> Your numbers suggest a cwnd growth then, which might show a CC bug.
> 
> Please run the following when your iper3 runs on regular 4.3 kernel
> 
> for i in `seq 1 10`
> do
> ss -temoi dst 192.168.0.141
> sleep 1
> done
> 

Another thing to try is to change tcp_limit_output_bytes back to 131072

Of course, your driver be the problem as well, but I am guessing it is
not upstream ?
