From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ofa-general] Re: [PATCH v3 08/13] QLogic VNIC: sysfs interface
	implementation for the driver
Date: Thu, 05 Jun 2008 19:32:59 +0200
Message-ID: <4848234B.1080200@trash.net>
References: <20080529095126.9943.84692.stgit@localhost.localdomain>	<20080529095754.9943.27936.stgit@localhost.localdomain>	<20080529103003.010c4a08@extreme>	<20080529174805.GA10903@kroah.com>	<c8028d330806031125x4181d8e3p9cdaf1f4c79e88c6@mail.gmail.com>	<1212518703.2217.22.camel@lap75545.ornl.gov>	<aday75k1pzh.fsf@cisco.com>	<20080605054035.GA8059@ornl.gov>	<adazlpzzvjn.fsf@cisco.com>
	<20080605100103.38ce7c4b@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Amar Mudrankit <amar.mudrankit@qlogic.com>, Dave Dillow <dillowda@ornl.gov>,
	Greg KH <greg@kroah.com>, Roland Dreier <rdreier@cisco.com>,
	general@lists.openfabrics.org, netdev@vger.kernel.org,
	poornima.kamath@qlogic.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080605100103.38ce7c4b@extreme>
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

Stephen Hemminger wrote:
> On Thu, 05 Jun 2008 09:38:36 -0700
> Roland Dreier <rdreier@cisco.com> wrote:
> 
>>  > That said, given that SRP's been using sysfs since it went in, is there
>>  > a reason to move to configfs other than it's the new preferred way to do
>>  > it? Given the desire to not break ABI's -- and IIRC sysfs was declared to
>>  > be under that unbrella -- wouldn't we have to at least carry both
>>  > interfaces for a while, assuming we can even get rid of the sysfs one?
>>
>> Yes, we'd definitely be carrying both interfaces for at least a year.
>>
>> Looking further into this, I'm not sure it makes much sense either.
>> Another problem with configfs is that the lifetime of the object is
>> controlled by userspace.  So if we lose a connection to a target,
>> the object will persist in configfs until userspace notices.
>>
>>  - R.
> 
> There is nothing stopping adding a well designed alternate interface.
> Either netlink or ioctl's are okay. As long as it is 32/64 bit clean.


 From a quick look it seems it should use rtnl_link instead
of adding yet another private sysfs interface.
