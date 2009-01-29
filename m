From: Andy Grover <andy.grover@oracle.com>
Subject: [ofa-general] Re: [PATCH 0/21] Reliable Datagram Sockets (RDS)
Date: Wed, 28 Jan 2009 17:29:40 -0800
Message-ID: <49810684.3010305@oracle.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
	<adaskn3ukey.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adaskn3ukey.fsf@cisco.com>
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
>  > This patchset adds support for RDS as an Infiniband ULP. RDS is an
>  > Oracle-originated protocol used to send IPC datagrams (up to 1MB) reliably,
>  > and is used currently in Oracle RAC and Exadata products. It's lived
>  > in OFED for 2+ years and I think it's time to get it upstream -- most
>  > likely into your -next tree for .30, but if it snuck into .29 via the
>  > "new code merge-window exception" then even better.
> 
> I'll read this over and comment, but to be honest I agree with Dave:
> this is a new socket family, and as such it belongs under net/ and
> probably should go through Dave's tree (just as the NFS/RDMA changes
> went through the NFS trees and the 9p/RDMA changes went through the 9p
> tree); even though it heavily uses RDMA I think the upper layer
> interface to sockets/networking is more relevant.

OK no prob. I'll probably be ready early next week with an updated patchset.

Thanks -- Regards -- Andy
