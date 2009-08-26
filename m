From: Patrick McHardy <kaber@trash.net>
Subject: Re: [BUG bisected] 2.6.30.4: NET: active FTP doesn't work
Date: Wed, 26 Aug 2009 14:51:23 +0200
Message-ID: <4A952FCB.6010101@trash.net>
References: <20090826083358.GB6010@pc11.op.pod.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Piotr Oledzki <ole@ans.pl>,
	Greg Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org
To: Vitezslav Samel <vitezslav@samel.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40167 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932901AbZHZMvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 08:51:24 -0400
In-Reply-To: <20090826083358.GB6010@pc11.op.pod.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vitezslav Samel wrote:
> 	Hi!
> 
>   When testing 2.6.30.4+ kernel, I discovered active ftp does not work
> anymore (2.6.30.3 is OK).
> 
>                LAN              internet
>    machine1  -------  router1   -------   machine2
> 
> 
>  Active ftp from machine1 to machine2 connects, transfers some files and
> then hangs. Passive ftp works OK. The faulty box (router1)
> is router/firewall and is doing NAT.
> 
>   I bisected it down to commit 7500f93f415a2fc07e0031d99fa3964bf8981cfc
> in linux-2.6.30.y tree ("netfilter: tcp conntrack: fix unacknowledged
> data detection with NAT").
> 
>   Could you, please, take look at it?

Please send me a tcpdump (binary dump, with -o <file> and -s0) of an
FTP session on both the internal and external interfaces and your NAT
rules. Thanks.
