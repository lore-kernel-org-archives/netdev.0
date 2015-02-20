From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 1/3] rhashtable: don't test for shrink on insert,
 expansion on delete
Date: Fri, 20 Feb 2015 11:13:38 +0100
Message-ID: <54E708D2.8030306@iogearbox.net>
References: <cover.1424389682.git.daniel@iogearbox.net> <55e6cbcc9c4b7a831d72d3e3ec39c024f494f9e2.1424389682.git.daniel@iogearbox.net> <063D6719AE5E284EB5DD2968C1650D6D1CAE675F@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "tgraf@suug.ch" <tgraf@suug.ch>,
	"johunt@akamai.com" <johunt@akamai.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ying Xue <ying.xue@windriver.com>
To: David Laight <David.Laight@ACULAB.COM>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52588 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754088AbbBTKNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 05:13:55 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAE675F@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/20/2015 11:08 AM, David Laight wrote:
...
> Does it actually make sense to shrink below the initial default size?

rhashtable has a min_shift parameter, shrinks cannot go below that.
