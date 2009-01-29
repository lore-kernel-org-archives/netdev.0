From: Andy Grover <andy.grover@oracle.com>
Subject: [ofa-general] Re: [PATCH 03/21] RDS: Congestion-handling code
Date: Wed, 28 Jan 2009 18:39:31 -0800
Message-ID: <498116E3.3060506@oracle.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>	<1233022678-9259-4-git-send-email-andy.grover@oracle.com>
	<ada7i4fujia.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <ada7i4fujia.fsf@cisco.com>
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

Roland Dreier wrote:
>  > +EXPORT_SYMBOL_GPL(rds_cong_map_updated);
> 
> What is this being exported to?  AFAICT you are only building a single
> RDS module, right?

In the current RDS development repo, transports are modularizable. For
the initial upstream submission I just wanted to include the IB
transport so I changed the build to compile rds-core and rds-ib
together, but didn't pull out the exports.

Steve Wise is working on having the iwarp transport debugged in the near
future. Once that is added and we make transports modularizable then
those exports are needed.

Take them out for now, then?

Thanks -- Regards -- Andy
