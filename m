From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: [ofa-general] [PATCH] net/inet_lro: remove setting	skb->ip_summed
	when not LRO-able
Date: Wed, 25 Jun 2008 16:01:18 +0300
Message-ID: <4862419E.5040307@voltaire.com>
References: <OFEBCC17DD.4CE7F0B2-ONC1257473.003ED3DA-C1257473.003EE40F@de.ibm.com>	
	<4862304D.2050306@voltaire.com> <1214397005.23583.60.camel@mtls03>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>,
	Vladimir Sokolovsky <vlad@mellanox.co.il>,
	OpenFabrics General <general@lists.openfabrics.org>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>
To: eli@dev.mellanox.co.il
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1214397005.23583.60.camel@mtls03>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Eli Cohen wrote:
> We already have this comment:
> 	u32 ip_summed;      /* Set in non generated SKBs in page mode */
>
> I think we should use have it something like that:
> 	/*
> 	 * Set for generated SKBs in that are not added to
> 	 * the frag list in fragmented mode
> 	 */
> 	u32 ip_summed;
>
> What do you think?
>   
yes, this could be a little more clear.


Or
