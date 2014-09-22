From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: ipv4 dead route delete notification on netdev down
Date: Mon, 22 Sep 2014 10:26:10 +0200
Message-ID: <541FDD22.7050807@6wind.com>
References: <541E4DD4.1050609@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Thomas Graf <tgraf@suug.ch>
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:63395 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753498AbaIVI0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 04:26:13 -0400
Received: by mail-wi0-f181.google.com with SMTP id z2so2451368wiv.8
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 01:26:11 -0700 (PDT)
In-Reply-To: <541E4DD4.1050609@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 21/09/2014 06:02, Roopa Prabhu a =E9crit :
> Hi,
>
> The kernel does not send notification for deleted dead ipv4 routes on=
 netdev down.
Not only on netdev down. If you remove the last IPv4 address, the kerne=
l will
also purge its routing table without any notification :/
