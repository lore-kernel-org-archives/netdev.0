From: jamal <hadi@cyberus.ca>
Subject: Re: hard hang through qdisc
Date: Thu, 31 Jan 2008 07:34:01 -0500
Message-ID: <1201782841.4732.11.camel@localhost>
References: <200801311321.01015.ak@suse.de>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:13005 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755006AbYAaN07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 08:26:59 -0500
Received: by py-out-1112.google.com with SMTP id u52so996192pyb.10
        for <netdev@vger.kernel.org>; Thu, 31 Jan 2008 05:26:57 -0800 (PST)
In-Reply-To: <200801311321.01015.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-31-01 at 13:21 +0100, Andi Kleen wrote:
> 
> I just managed to hang a 2.6.24 (+ some non network patches) kernel 
> with the following (non sensical) command
> 
> tc qdisc add dev eth0 root tbf rate 1000 burst 10 limit 100
> 
> No oops or anything just hangs. While I understand root can
> do bad things just hanging like this seems a little extreme.
> 

---------
lilsol:~# tc qdisc add dev eth0 root tbf rate 1000 burst 10 limit 100
lilsol:~# uname -a
Linux lilsol 2.6.24 #1 PREEMPT Sun Jan 27 09:22:00 EST 2008 i686
GNU/Linux
lilsol:~# tc qdisc ls dev eth0
qdisc tbf 8001: root rate 1000bit burst 10b lat 737.3ms
lilsol:~#
-------

What do your patches do?

cheers,
jamal


