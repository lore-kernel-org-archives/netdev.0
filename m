From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: Re: [PATCH net-next 0/5] qed/qede: Tunnel hardware GRO support
Date: Fri, 24 Jun 2016 05:20:55 +0000
Message-ID: <CO2PR11MB0088862F73DF6A1F99DDAA6D972E0@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
 <CAKgT0Ue6_cPb88wfTtMMetJzBSJnGDNWj8YVHWC=9WdztCxOuQ@mail.gmail.com>
 <CO2PR11MB008891D4ECFF86F32B1C32CC972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0UdDt6H8ix6U7n_uPjodkXYuxviZjSKWQRaXu2_qWWEL+A@mail.gmail.com>
 <CO2PR11MB0088C4DEAFEE71B0D865DB33972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <576B08A2.8080603@hpe.com>
 <1466635664.6850.90.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0UdbPVqpSVLs0JW7zFU7mNtJn5BM+fMjsr1tLm4kHRcW9A@mail.gmail.com>
 <1466638292.6850.94.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0Uex41aBJX84we2gxNGw6M4s5xGEPnDkGehTZkEE+i+Jhw@mail.gmail.com>
 <CO2PR11MB0088B3C577EC110B845C17B3972D0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CO2PR11MB0088949623FA99ED86D33205972D0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0Uc7cCu-5SwrB+4Mv6OM+V1jDwefOoG-Wr61C4F1g1BmFA@mail.gmail.com>
 <CO2PR11MB00884BBC91DE36D3FA78796C972D0@CO2PR11MB0088.namprd11.prod.outlook.com>,<CAKgT0UfPFsv6aH9aQQPD3gZ_0netSS85-mNLnb1bGjvtdyu6fw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hpe.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	"Tom Herbert" <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0118.outbound.protection.outlook.com ([207.46.100.118]:55395
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750966AbcFXFU7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 01:20:59 -0400
In-Reply-To: <CAKgT0UfPFsv6aH9aQQPD3gZ_0netSS85-mNLnb1bGjvtdyu6fw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>We already know of one firmware bug you guys have which makes 
>it clear that the bnx2x is not doing hardware assisted GRO it is doing 
>something else since it performs much worse than GRO if the MSS is 
>less than what it would be based on the MTU.

It's a bit nitpicky, isn't it? Claiming this flaw means it's not GRO.
I.e., you obviously wouldn't have claimed it beacme GRO if it
was fixed.

Not saying it makes a lot of difference, though.
