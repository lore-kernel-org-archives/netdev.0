From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] Re: [PATCH v3 08/13] QLogic VNIC: sysfs interface
	implementation for the driver
Date: Thu, 05 Jun 2008 13:47:39 -0700
Message-ID: <adave0nzk0k.fsf@cisco.com>
References: <20080529095126.9943.84692.stgit@localhost.localdomain>
	<20080529095754.9943.27936.stgit@localhost.localdomain>
	<20080529103003.010c4a08@extreme> <20080529174805.GA10903@kroah.com>
	<c8028d330806031125x4181d8e3p9cdaf1f4c79e88c6@mail.gmail.com>
	<1212518703.2217.22.camel@lap75545.ornl.gov>
	<aday75k1pzh.fsf@cisco.com> <20080605054035.GA8059@ornl.gov>
	<adazlpzzvjn.fsf@cisco.com> <20080605100103.38ce7c4b@extreme>
	<4848234B.1080200@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amar Mudrankit <amar.mudrankit@qlogic.com>, Dave Dillow <dillowda@ornl.gov>,
	Greg KH <greg@kroah.com>, general@lists.openfabrics.org,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	poornima.kamath@qlogic.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <4848234B.1080200@trash.net> (Patrick McHardy's message of "Thu,
	05 Jun 2008 19:32:59 +0200")
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

 > > There is nothing stopping adding a well designed alternate interface.
 > > Either netlink or ioctl's are okay. As long as it is 32/64 bit clean.

 > From a quick look it seems it should use rtnl_link instead
 > of adding yet another private sysfs interface.

This seems crazy -- why do we want to push things towards the complexity
of rtnl_link instead of a simple text-based interface that can be
trivial used with 'echo' from the shell?  What advantages does that
give?

 - R.
