From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net 2/2] rhashtable: remove indirection for grow/shrink
 decision functions
Date: Wed, 25 Feb 2015 15:51:10 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAED3A1@AcuExch.aculab.com>
References: <cover.1424877322.git.daniel@iogearbox.net>
 <cd3e70163920753c7f1a492e6df253cff9b1b080.1424877322.git.daniel@iogearbox.net>
 <063D6719AE5E284EB5DD2968C1650D6D1CAED36D@AcuExch.aculab.com>
 <54EDEE55.8050605@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "tgraf@suug.ch" <tgraf@suug.ch>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"johunt@akamai.com" <johunt@akamai.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Daniel Borkmann' <daniel@iogearbox.net>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.181]:63707 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752549AbbBYPwP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 10:52:15 -0500
In-Reply-To: <54EDEE55.8050605@iogearbox.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann [ 
> On 02/25/2015 04:41 PM, David Laight wrote:
> ...
> > Why not cache the 'number of items before we need to expand' value
> > after each expansion, setting it to 'infinite' when expansion is disabled.
> > Then the above check is a simple comparison.
> > You probably don't even need an atomic_read() - provided something is
> > double checked once the first test determines that an expansion is needed.
> 
> Did you read my cover letter? ;)

I probably didn't infer the relevant references :-)

Actually even if some code wanted other rules, provided they
are based on comparing the 'number of items' to a preset limit
the limit could be set during expansion/contraction.

	David
