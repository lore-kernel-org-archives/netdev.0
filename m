From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net 2/3] rhashtable: better high order allocation
 attempts
Date: Fri, 20 Feb 2015 10:11:00 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAE676F@AcuExch.aculab.com>
References: <cover.1424389682.git.daniel@iogearbox.net>
 <ef7f956fc36000761a652f2bcb395d0eb7300802.1424389682.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "tgraf@suug.ch" <tgraf@suug.ch>,
	"johunt@akamai.com" <johunt@akamai.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Daniel Borkmann' <daniel@iogearbox.net>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.181]:58274 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753745AbbBTKLx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 05:11:53 -0500
In-Reply-To: <ef7f956fc36000761a652f2bcb395d0eb7300802.1424389682.git.daniel@iogearbox.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann
> When trying to allocate future tables via bucket_table_alloc(), it seems
> overkill on large table shifts that we probe for kzalloc() unconditionally
> first, as it's likely to fail.

How about a two-level array for large tables?
Then you don't need to allocate more than 1 page at a time?

	David
