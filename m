From: "Dave, Tushar N" <tushar.n.dave@intel.com>
Subject: RE: [net] e1000: Small packets may get corrupted during padding by
 HW
Date: Mon, 17 Sep 2012 16:39:27 +0000
Message-ID: <061C8A8601E8EE4CA8D8FD6990CEA89130DC3B59@ORSMSX102.amr.corp.intel.com>
References: <061C8A8601E8EE4CA8D8FD6990CEA89130DC20AA@ORSMSX102.amr.corp.intel.com>
	<50552FF1.5030708@intel.com>
	<061C8A8601E8EE4CA8D8FD6990CEA89130DC3631@ORSMSX102.amr.corp.intel.com>
 <20120917.123113.458101376016589070.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Fastabend, John R" <john.r.fastabend@intel.com>,
	"mirqus@gmail.com" <mirqus@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:61531 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754704Ab2IQQj3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 12:39:29 -0400
In-Reply-To: <20120917.123113.458101376016589070.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>On Behalf Of David Miller
>Sent: Monday, September 17, 2012 9:31 AM
>To: Dave, Tushar N
>Cc: Fastabend, John R; mirqus@gmail.com; Kirsher, Jeffrey T;
>netdev@vger.kernel.org; gospo@redhat.com; sassmann@redhat.com
>Subject: Re: [net] e1000: Small packets may get corrupted during padding
>by HW
>
>From: "Dave, Tushar N" <tushar.n.dave@intel.com>
>Date: Mon, 17 Sep 2012 07:33:12 +0000
>
>> No because it is quite normal to have packet < ETH_ZLEN. e.g. ARP
>packets.
>
>You're optimizing for ARP packets?  You're kidding right?

ARP packet was just an example. I should have thought of better example.
