From: Andrew Grover <andy.grover@gmail.com>
Subject: [ofa-general] Re: [PATCH 01/21] RDS: Socket interface
Date: Wed, 28 Jan 2009 19:17:05 -0800
Message-ID: <c0a09e5c0901281917j4e37dbc7q28fee92d872e75fe@mail.gmail.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
	<1233022678-9259-2-git-send-email-andy.grover@oracle.com>
	<20090126194619.02c9557e@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20090126194619.02c9557e@extreme>
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

On Mon, Jan 26, 2009 at 7:46 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
>> +/* this is just used for stats gathering :/ */
>
> Then I would think a high speed protocol would use per-cpu
> and/or rcu.

For a spinlock guarding a socket list? I wouldn't think it would be
worth the complexity.

[other comments snipped, will fix per your advice, thanks!]

Regards -- Andy
