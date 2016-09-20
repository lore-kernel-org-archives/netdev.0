From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 2/2] bnx2x: allocate mac filtering pending list
 in PAGE_SIZE increments
Date: Tue, 20 Sep 2016 11:30:09 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB01046DB@AcuExch.aculab.com>
References: <cover.1474060371.git.jbaron@akamai.com>
 <d46b4fa36c32affff20fcc92148e33ee6176f899.1474060371.git.jbaron@akamai.com>
 <BL2PR07MB2306CEA6AD75D9D4EB77FB1F8DF50@BL2PR07MB2306.namprd07.prod.outlook.com>
 <57E02F82.9060903@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Ariel.Elior@qlogic.com" <Ariel.Elior@qlogic.com>
To: 'Jason Baron' <jbaron@akamai.com>,
        "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.186]:52859 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752901AbcITLco (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 07:32:44 -0400
In-Reply-To: <57E02F82.9060903@akamai.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Baron
> Sent: 19 September 2016 19:34
...
> 
> sizeof(struct bnx2x_mcast_list_elem) = 24. So there are 170 per
> page on x86. So if we want to fit 2,048 elements, we need 12 pages.

If you only need to save the mcast addresses you could use a 'heap'
that requires no overhead per entry and gives you O(log) lookup.
6 bytes per entry is 682 in a 4k page.

	David
