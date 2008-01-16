From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: Packetlost when "tc qdisc del dev eth0 root"
Date: Wed, 16 Jan 2008 11:35:35 +0300
Message-ID: <478DC1D7.90401@bigtelecom.ru>
References: <478C94B7.3070503@bigtelecom.ru> <478CD9D6.3000504@trash.net> <478D226E.1050209@gmail.com> <478D8FC8.9000107@trash.net> <20080116080259.GB1638@ff.dom.local> <478DBADB.1080200@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:33457 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757548AbYAPIfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 03:35:43 -0500
In-Reply-To: <478DBADB.1080200@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>
>
> Yes, thats one possibility (without the dummy device though please).
> But I wonder what this would actually be useful for. I don't think
> replacing the root qdisc by a different type is a common scenario,
> for the same type you can simply use "tc qdisc change", "tc class
> change" and "tc class replace".
>
> Badalian, what are you actually doing?
>
Sorry. Resend to all.

I simple recreate all rules. I change idea from do many 
add,change,delete because have many kernel panics on many kernels 2.6.x
First i have panics on "delete filter" operation... was fix it... 
great.. then have panics on "delete htb" operation... long time wait to 
fix it (maintainer of tc not have time to fix it i think).. but have 1-5 
panics at day.... i think my clients hate  me =) i rewrite script to 
simple  recreate all rules... in this method i have small packetlost 1 
time in hour (then recreate root qdisc), but not have panics... now i 
use new logic of scripts... =)
maybe need go back to accurate logic of scripts, but i to fear kernel 
panics =)

P.S. Feature request:
tc class show [ dev STRING ] [ root | parent CLASSID ]
may add classid filter to show?
i need do like this
/sbin/tc -s class show dev eth0 | grep -A2 "htb $HTB "
to get stats of class... but i every run real look all table.. its not good

Thanks that are you interesting history of my problems =)
Slavon.

