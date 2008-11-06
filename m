From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [ofa-general] Re: Re: [PATCH] mlx4_en: Pause parameters per port
Date: Thu, 06 Nov 2008 08:53:40 +0200
Message-ID: <49129474.1030607@mellanox.co.il>
References: <4911B244.30205@mellanox.co.il> <49128472.7080607@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>,
	general@lists.openfabrics.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <49128472.7080607@pobox.com>
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

Jeff Garzik wrote:
> Is this a regression fix?  It doesn't look like one to me, so I am
> planning to hold this for 2.6.29 (davem/net-next-2.6.git), unless there
> are problems with this plan?
> 

This is regression fix. When setting pause parameters for one port, they would only change for that port,
but both of the ports report the same parameters. It means that the second port reports wrong pause parameters.

Yevgeny
