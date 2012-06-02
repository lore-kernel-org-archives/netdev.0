From: Andy Furniss <andyqos@ukfsn.org>
Subject: Re: [Announce] LARTC wiki available
Date: Sat, 02 Jun 2012 15:43:58 +0100
Message-ID: <4FCA26AE.30009@ukfsn.org>
References: <4EFB3B2B.7060200@linuxsystems.it> <4FC8F0E4.6060102@linuxsystems.it> <8063b8e35d17fd072cbdc9908cf12519@njm.linuxwall.info> <4FCA2545.60702@ukfsn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?TmljY29sw7IgQmVsbGk=?= <darkbasic@linuxsystems.it>,
	lartc@vger.kernel.org, netfilter@vger.kernel.org,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: Julien Vehent <julien@linuxwall.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ukfsn.org ([77.75.108.3]:34839 "EHLO mail.ukfsn.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759241Ab2FBPoA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Jun 2012 11:44:00 -0400
In-Reply-To: <4FCA2545.60702@ukfsn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Furniss wrote:

> I tested (maybe not hard enough) quantum < mtu and never managed to
> prevent dequeues - I know it's not efficient and "forbiden" but back
> then at least it didn't break.

Forgot to say -

also remember mtu as seen by tc on eth has 14 added - default quantum on 
sfq, htb etc are 1514 as you can see with tc -s -d qdisc ls etc.
