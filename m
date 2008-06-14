From: "Roland Dreier" <roland.list@gmail.com>
Subject: Re: [ofa-general] Re: [PATCH v4 14/14] QLogic VNIC: sysfs
	Documentation
Date: Sat, 14 Jun 2008 11:03:08 -0700
Message-ID: <f8ca0a150806141103r56f0530br6b5e78943ac1c92d@mail.gmail.com>
References: <20080610205633.11186.45499.stgit@dale>
	<20080610210918.11186.64253.stgit@dale> <484F751F.7030407@trash.net>
	<c8028d330806120813q6363c3cemb4aa03ceff6547d1@mail.gmail.com>
	<48513E4E.4040601@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, poornima.kamath@qlogic.com,
	general@lists.openfabrics.org, Amar Mudrankit <amar.mudrankit@qlogic.com>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <48513E4E.4040601@trash.net>
Content-Disposition: inline
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

> We have linkstate/operstate for this. How is a user supposed
> to configure the network device when it appears at a more or
> less random time from his perspective?

Well, keep in mind that this driver is for an ethernet virtual NIC
that is actually
remote across another network (an InfiniBand fabric) -- so these devices
can actually appear or disappear at random times by their nature.  It's a
similar issue to, say, a USB ethernet adapter presents -- there's no sane way
to have operstate set for a device that hasn't been attached yet.

 - R.
