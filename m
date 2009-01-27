From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: [ofa-general] Re: [PATCH 04/21] RDS: Transport code
Date: Wed, 28 Jan 2009 00:56:58 +0300
Message-ID: <20090127215657.GD12431@ioremap.net>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
	<1233022678-9259-5-git-send-email-andy.grover@oracle.com>
	<20090127131808.GF2646@ioremap.net>
	<c0a09e5c0901271136h4ac81f28g143d1b084cc1076@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rdreier@cisco.com, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org
To: Andrew Grover <andy.grover@gmail.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <c0a09e5c0901271136h4ac81f28g143d1b084cc1076@mail.gmail.com>
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

On Tue, Jan 27, 2009 at 11:36:37AM -0800, Andrew Grover (andy.grover@gmail.com) wrote:
> On Tue, Jan 27, 2009 at 5:18 AM, Evgeniy Polyakov <zbr@ioremap.net> wrote:
> > On Mon, Jan 26, 2009 at 06:17:41PM -0800, Andy Grover (andy.grover@oracle.com) wrote:
> >> +static LIST_HEAD(transports);
> >> +static DECLARE_RWSEM(trans_sem);
> >> +
> >
> > RDS_ prefix?
> 
> Even needed for statics?

It confuses tags and the like otherwise, and looks more consistent with
the rest of the code. Likely it is not a must, but just better look.

-- 
	Evgeniy Polyakov
