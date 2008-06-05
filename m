From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ofa-general] Re: [PATCH v3 08/13] QLogic VNIC: sysfs interface
	implementation for the driver
Date: Fri, 06 Jun 2008 00:54:49 +0200
Message-ID: <48486EB9.4010706@trash.net>
References: <20080529095126.9943.84692.stgit@localhost.localdomain>	<20080529095754.9943.27936.stgit@localhost.localdomain>	<20080529103003.010c4a08@extreme>
	<20080529174805.GA10903@kroah.com>	<c8028d330806031125x4181d8e3p9cdaf1f4c79e88c6@mail.gmail.com>	<1212518703.2217.22.camel@lap75545.ornl.gov>	<aday75k1pzh.fsf@cisco.com>
	<20080605054035.GA8059@ornl.gov>	<adazlpzzvjn.fsf@cisco.com>
	<20080605100103.38ce7c4b@extreme>	<4848234B.1080200@trash.net>
	<adave0nzk0k.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Amar Mudrankit <amar.mudrankit@qlogic.com>, Dave Dillow <dillowda@ornl.gov>,
	Greg KH <greg@kroah.com>, general@lists.openfabrics.org,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	poornima.kamath@qlogic.com
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adave0nzk0k.fsf@cisco.com>
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
>  > > There is nothing stopping adding a well designed alternate interface.
>  > > Either netlink or ioctl's are okay. As long as it is 32/64 bit clean.
>
>  > From a quick look it seems it should use rtnl_link instead
>  > of adding yet another private sysfs interface.
>
> This seems crazy -- why do we want to push things towards the complexity
> of rtnl_link instead of a simple text-based interface that can be
> trivial used with 'echo' from the shell?

Its not complicated at all. Ability to use "echo" seems like a
pretty poor argument to me.

>   What advantages does that give?

- atomic configuration changes
- atomic configuration dumps
- configuration change notifications
- same interface as for all other network-related configurations
- easily extensible
- not yet another private driver interface
- not text based, which makes it a lot more convenient for using in programs
