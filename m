From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 2/2] rhashtable: remove indirection for grow/shrink
 decision functions
Date: Wed, 25 Feb 2015 10:15:17 -0800
Message-ID: <1424888117.5565.113.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1424877322.git.daniel@iogearbox.net>
	 <cd3e70163920753c7f1a492e6df253cff9b1b080.1424877322.git.daniel@iogearbox.net>
	 <063D6719AE5E284EB5DD2968C1650D6D1CAED36D@AcuExch.aculab.com>
	 <54EDEE55.8050605@iogearbox.net>
	 <063D6719AE5E284EB5DD2968C1650D6D1CAED3A1@AcuExch.aculab.com>
	 <54EDF4DD.1060709@iogearbox.net>
	 <1424886096.5565.104.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CAED645@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"johunt@akamai.com" <johunt@akamai.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:34137 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753013AbbBYSPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 13:15:19 -0500
Received: by iecrp18 with SMTP id rp18so7305005iec.1
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 10:15:19 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAED645@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-02-25 at 17:49 +0000, David Laight wrote:

> That won't work if someone is managing to break the hash function.
> You need some approximation to the total count as well.
> OTOH there is no point growing the table if the current list isn't 'full'.

Well, if hash function is broken, having 1,000,000 elements in one
bucket will kill your host, even if hash table has 1 million buckets.

Better find this out sooner than later.
