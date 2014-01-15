From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net] bpf: do not use reciprocal divide
Date: Wed, 15 Jan 2014 08:09:15 -0800
Message-ID: <1389802155.31367.348.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140113214249.GK6586@order.stressinduktion.org>
	 <1389769361.31367.325.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140115080007.GA6638@osiris> <20140115091322.3a7740a7@mschwide>
	 <20140115105114.GB6638@osiris>
	 <1389795716.31367.333.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1389795926.31367.334.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1389797407.31367.340.camel@edumazet-glaptop2.roam.corp.google.com>
	 <927a6073e8f73b53027480e7609b4c53@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, dborkman@redhat.com,
	darkjames-ws@darkjames.pl, Mircea Gherzan <mgherzan@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>
To: Matt Evans <matt@ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:60082 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869AbaAOQJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 11:09:17 -0500
Received: by mail-pb0-f46.google.com with SMTP id ma3so1313826pbc.19
        for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 08:09:17 -0800 (PST)
In-Reply-To: <927a6073e8f73b53027480e7609b4c53@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-15 at 15:10 +0000, Matt Evans wrote:
> Hi Eric,
...
> PPC looks fine; I had a look at the core/ARM parts which also look good.
> 
> I'd forgotten where the DIV0 checking occurred, so I also benefited from 
> your hint to Heiko. :)
> 

Thanks for reviewing !
