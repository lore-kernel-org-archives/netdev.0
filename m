From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] Re: [PATCH v3 08/13] QLogic VNIC: sysfs interface
	implementation for the driver
Date: Thu, 05 Jun 2008 09:38:36 -0700
Message-ID: <adazlpzzvjn.fsf@cisco.com>
References: <20080529095126.9943.84692.stgit@localhost.localdomain>
	<20080529095754.9943.27936.stgit@localhost.localdomain>
	<20080529103003.010c4a08@extreme> <20080529174805.GA10903@kroah.com>
	<c8028d330806031125x4181d8e3p9cdaf1f4c79e88c6@mail.gmail.com>
	<1212518703.2217.22.camel@lap75545.ornl.gov>
	<aday75k1pzh.fsf@cisco.com> <20080605054035.GA8059@ornl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amar Mudrankit <amar.mudrankit@qlogic.com>, Greg KH <greg@kroah.com>,
	general@lists.openfabrics.org, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>, poornima.kamath@qlogic.com
To: Dave Dillow <dillowda@ornl.gov>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080605054035.GA8059@ornl.gov> (Dave Dillow's message of "Thu,
	5 Jun 2008 01:40:35 -0400")
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

 > That said, given that SRP's been using sysfs since it went in, is there
 > a reason to move to configfs other than it's the new preferred way to do
 > it? Given the desire to not break ABI's -- and IIRC sysfs was declared to
 > be under that unbrella -- wouldn't we have to at least carry both
 > interfaces for a while, assuming we can even get rid of the sysfs one?

Yes, we'd definitely be carrying both interfaces for at least a year.

Looking further into this, I'm not sure it makes much sense either.
Another problem with configfs is that the lifetime of the object is
controlled by userspace.  So if we lose a connection to a target,
the object will persist in configfs until userspace notices.

 - R.
