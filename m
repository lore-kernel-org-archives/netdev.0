From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 1/3] net: bcmgenet: cleanup for bcmgenet_xmit()
Date: Wed, 6 Apr 2016 08:57:28 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D54DC5E88@AcuExch.aculab.com>
References: <1459815001-91703-1-git-send-email-pgynther@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"jaedon.shin@gmail.com" <jaedon.shin@gmail.com>
To: 'Petri Gynther' <pgynther@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.181]:54415 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933215AbcDFI6u convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 04:58:50 -0400
In-Reply-To: <1459815001-91703-1-git-send-email-pgynther@google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther
> Sent: 05 April 2016 01:10
...
> 2. Readability: Add parentheses around nr_frags + 1.
...
> -	if (ring->free_bds <= nr_frags + 1) {
...
> +	if (ring->free_bds <= (nr_frags + 1)) {

The extra () are not needed and do not improve readability.

	David
