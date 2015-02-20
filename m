From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 2/3] rhashtable: better high order allocation attempts
Date: Fri, 20 Feb 2015 11:23:18 +0100
Message-ID: <54E70B16.70402@iogearbox.net>
References: <cover.1424389682.git.daniel@iogearbox.net> <ef7f956fc36000761a652f2bcb395d0eb7300802.1424389682.git.daniel@iogearbox.net> <063D6719AE5E284EB5DD2968C1650D6D1CAE676F@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "tgraf@suug.ch" <tgraf@suug.ch>,
	"johunt@akamai.com" <johunt@akamai.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53556 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753512AbbBTKXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 05:23:33 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAE676F@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/20/2015 11:11 AM, David Laight wrote:
...
> How about a two-level array for large tables?
> Then you don't need to allocate more than 1 page at a time?

Sorry, I currently don't see how this fits into the rhashtable
algorithm i.e. with regards to the expansion and shrink logic?
