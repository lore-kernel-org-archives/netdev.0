From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: use hardware buffer pool to allocate skb
Date: Fri, 17 Oct 2014 11:53:00 -0700
Message-ID: <1413571980.25949.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>
	 <20141015.002514.384962932982389732.davem@davemloft.net>
	 <c02005b9d8794d14bc2149f468ab571c@BY2PR03MB524.namprd03.prod.outlook.com>
	 <1413364533.12304.44.camel@edumazet-glaptop2.roam.corp.google.com>
	 <524626e093684abeba65839d26e94262@BLUPR03MB517.namprd03.prod.outlook.com>
	 <1413432912.28798.7.camel@edumazet-glaptop2.roam.corp.google.com>
	 <aeef795129504782ae1e9f91467d243e@BLUPR03MB517.namprd03.prod.outlook.com>
	 <543FE413.6030406@redhat.com>
	 <1413478657.28798.22.camel@edumazet-glaptop2.roam.corp.google.com>
	 <543FFC03.1060207@redhat.com>
	 <1413481529.28798.29.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54400C6C.7010405@redhat.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1C9D895B@AcuExch.aculab.com>
	 <54412A59.7070508@redhat.com>
	 <1413564913.24709.7.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54415FEA.5000705@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	"Jiafei.Pan@freescale.com" <Jiafei.Pan@freescale.com>,
	David Miller <davem@davemloft.net>,
	"jkosina@suse.cz" <jkosina@suse.cz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"LeoLi@freescale.com" <LeoLi@freescale.com>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <54415FEA.5000705@redhat.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-10-17 at 11:28 -0700, Alexander Duyck wrote:

> Yes, I am well aware of this bit.  That is my concern.  You increase the 
> size for truesize, it will cut the amount of queueing in half, and then 
> igb will start seeing drops when it has to deal with bursty traffic and 
> people will start to complain about a performance regression.  That is 
> the bit I want to avoid.

Then, what about addressing the issue for good, instead of working
around it ?

Don't worry, I will work on it.

We also are working on a direct placement in memory for TCP receive
path. (equivalent of sendfile() but for receiver), to avoid the need to 
hold payload in kernel memory (out of order queues)



