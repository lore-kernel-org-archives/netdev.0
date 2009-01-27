From: Andrew Grover <andy.grover@gmail.com>
Subject: [ofa-general] Re: [PATCH 02/21] RDS: Main header file
Date: Tue, 27 Jan 2009 11:27:34 -0800
Message-ID: <c0a09e5c0901271127s74397271uf9a86ba51c25a156@mail.gmail.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
	<1233022678-9259-3-git-send-email-andy.grover@oracle.com>
	<200901270934.16669.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, rdreier@cisco.com, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org
To: =?ISO-8859-1?Q?R=E9mi_Denis=2DCourmont?= <remi.denis-courmont@nokia.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <200901270934.16669.remi.denis-courmont@nokia.com>
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

On Mon, Jan 26, 2009 at 11:34 PM, R=E9mi Denis-Courmont
<remi.denis-courmont@nokia.com> wrote:

>> +#ifndef PF_RDS
>> +#define PF_RDS          AF_RDS
>> +#endif
>
> You should probably remove that and put the last patch of your series ahe=
ad of
> this one.

Yup will do.

>> +#ifndef SOL_RDS
>> +#define SOL_RDS         272
>> +#endif
>
> This is used by RXRPC nowadays, although I myself don't really understand=
 why
> socket option levels need to be unique across all families.

OK, shouldn't be too hard to fix.

Thanks.

Regards -- Andy
