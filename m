From: =?iso-8859-1?Q?Hans_Schillstr=F6m?= <hans.schillstrom@ericsson.com>
Subject: RE: [PATCH] netfilter: xt_HMARK: endian bugs
Date: Tue, 15 May 2012 07:57:22 +0200
Message-ID: <C8A6796DE7C66C4ABCBC18106CB6C1CC164B83BE11@ESESSCMS0356.eemea.ericsson.se>
References: <1337002943-16374-1-git-send-email-hans.schillstrom@ericsson.com>
	 <201205141809.18174.hans.schillstrom@ericsson.com>
	 <1337012674.8512.589.camel@edumazet-glaptop>
	 <201205141951.36692.hans.schillstrom@ericsson.com>
	 <alpine.DEB.2.00.1205142032570.28548@blackhole.kfki.hu>
	 <20120514190211.GC14897@1984>,<1337022835.8512.610.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jan Engelhardt <jengelh@inai.de>,
	"kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"dan.carpenter@oracle.com" <dan.carpenter@oracle.com>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1337022835.8512.610.camel@edumazet-glaptop>
Content-Language: en-US
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>On Mon, 2012-05-14 at 21:02 +0200, Pablo Neira Ayuso wrote:
>
>> IIRC, Hans wants that, in case you have a cluster composed of system
>> with different endianess, the hash mark calculated will be the same
>> in both systems. To ensure that the distribution is consistent with
>> independency of the endianess.
>
>Then jhash() must be audited to make sure its output is OK with this
>requirement.

Have done that, and made tests on a mips 32 running debian
It was as expected jhash3_words is endian safe, while jhash() is not





