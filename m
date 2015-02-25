From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 2/2] rhashtable: remove indirection for grow/shrink
 decision functions
Date: Wed, 25 Feb 2015 16:46:29 +0100
Message-ID: <54EDEE55.8050605@iogearbox.net>
References: <cover.1424877322.git.daniel@iogearbox.net> <cd3e70163920753c7f1a492e6df253cff9b1b080.1424877322.git.daniel@iogearbox.net> <063D6719AE5E284EB5DD2968C1650D6D1CAED36D@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "tgraf@suug.ch" <tgraf@suug.ch>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"johunt@akamai.com" <johunt@akamai.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53277 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752345AbbBYPqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 10:46:44 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAED36D@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/25/2015 04:41 PM, David Laight wrote:
...
> Why not cache the 'number of items before we need to expand' value
> after each expansion, setting it to 'infinite' when expansion is disabled.
> Then the above check is a simple comparison.
> You probably don't even need an atomic_read() - provided something is
> double checked once the first test determines that an expansion is needed.

Did you read my cover letter? ;)
