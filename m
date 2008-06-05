From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] Re: [PATCH v3 08/13] QLogic VNIC: sysfs	interface
	implementation for the driver
Date: Wed, 04 Jun 2008 21:10:26 -0700
Message-ID: <aday75k1pzh.fsf@cisco.com>
References: <20080529095126.9943.84692.stgit@localhost.localdomain>
	<20080529095754.9943.27936.stgit@localhost.localdomain>
	<20080529103003.010c4a08@extreme> <20080529174805.GA10903@kroah.com>
	<c8028d330806031125x4181d8e3p9cdaf1f4c79e88c6@mail.gmail.com>
	<1212518703.2217.22.camel@lap75545.ornl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amar Mudrankit <amar.mudrankit@qlogic.com>, Greg KH <greg@kroah.com>,
	general@lists.openfabrics.org, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>, poornima.kamath@qlogic.com
To: David Dillow <dillowda@ornl.gov>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1212518703.2217.22.camel@lap75545.ornl.gov> (David Dillow's
	message of "Tue, 03 Jun 2008 14:45:03 -0400")
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

 > Or so the theory goes. Unfortunately, you need all that information
 > before you can create the connection. The configfs guys have thought
 > about that, but not implemented yet:
 > 
 > > [Committable Items]
 > > NOTE: Committable items are currently unimplemented.

The netconsole code in-tree has a separate "enabled" attribute that
serves the purpose of "committing" something.  Seems good enough for SRP
to use to me... the rename to commit idea seems cute but I don't see
that it buys much beyond this.
