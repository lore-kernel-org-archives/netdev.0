From: "John Russo" <john.russo@qlogic.com>
Subject: RE: Fwd: [ofa-general] FW: QLogic vNIC Kernel Submission
Date: Tue, 17 Jun 2008 15:12:49 -0500
Message-ID: <99863D2ED484D449811D97A4C44C9CBD7C5169@EPEXCH2.qlogic.org>
References: <99863D2ED484D449811D97A4C44C9CBD7C50F7@EPEXCH2.qlogic.org><c8028d330806171018j7f129ddft3bee056e4be9b954@mail.gmail.com><485803D3.5020505@trash.net> <20080617121441.4b87ba84@extreme> <C07C40DB2364324799506DE8FF12F8D859E90D@EPEXCH1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Amar Mudrankit \(Contractor - \)" <amar.mudrankit@qlogic.com>,
	<netdev@vger.kernel.org>, <rdreier@cisco.com>,
	"Kuchimanchi, Ramachandra \(Contractor - \)"
	<ramachandra.kuchimanchi@qlogic.com>,
	"Poornima Kamath \(Contractor - \)" <poornima.kamath@qlogic.com>
To: <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eppat.qlogic.com ([198.186.5.11]:54454 "EHLO EPEXCH2.qlogic.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753138AbYFQU2D convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 16:28:03 -0400
Content-class: urn:content-classes:message
In-Reply-To: <C07C40DB2364324799506DE8FF12F8D859E90D@EPEXCH1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen,

>> Understand that this is a community process and it isn't going to
follow 
>> a corporate model. There is no external pressures like schedules and
>> users.

With all due respect...
In my mind, that is just not realistic.  Work done in this community has
very strong corporate repercussions and these issues can't simply be
ignored. I am not saying that the community should ever alter their
ideals for any company, just that some people/groups/companies will be
reluctant to even try to contribute if they feel that guidelines like
this can be changed this way and make their efforts wasted.

>> As Patrick said, there is also a sense of doing the right thing. The 
>> developers would rather not repeat past mistakes, so are naturally 
>> hesitant on API's.

I completely understand the sense of doing the right thing. That is why
we put in the effort to migrate our code to sysfs in the first place.
We had a different solution but agreed to change it to meet the
guidelines of other contributors to the InfiniBand (OFED) stack.  What I
can't understand is the ease of which some people say "let's just change
to this great new design even if it means a large rewrite of existing
code which may increase the likelihood of injecting errors".  I
apologize if I come off as being agitated but it is very frustrating to
spend time and effort attempting to conform to a groups requests only to
have it changed at the end. 

>> Adding a device that follows existing API's is always much easier.
What 
>> you are seeing is in part an internal discomfort with the plethora of

>> API's and the binary baggage of ioctl's, sysfs, etc.

Again, I completely understand the level of discomfort.  We are trying
to work to the same 'rules' that other members of our community have
used.

>> If you could give a general outline of what the interface you want
would >> do, perhaps the community could provide some sample code that
do what you 
>> want.
>> Netlink interfaces are less common, and there are fewer examples.

-----Original Message-----
From: Stephen Hemminger [mailto:shemminger@vyatta.com]
Sent: Wed 6/18/2008 12:44 AM
To: Patrick McHardy
Cc: Amar Mudrankit (Contractor - ); netdev@vger.kernel.org;
rdreier@cisco.com; Kuchimanchi, Ramachandra (Contractor - ); Poornima
Kamath (Contractor - )
Subject: Re: Fwd: [ofa-general] FW: QLogic vNIC Kernel Submission
 
On Tue, 17 Jun 2008 20:34:59 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Amar Mudrankit wrote:
> > It looks as if my original email was "scrubbed" before it made the
> > mailing list so I am resending it...
> > 
> > QLogic has been attempting to submit our virtual NIC (vNIC) driver
to
> > the Linux kernel for several months.  We have made changes to the
code
> > based on the feedback we have received over four rounds of
> > submissions. Among the feedback we received during this process was
a
> > request to alter our code to use a single value per file for
> > configuration of our driver through sysfs interface.  After spending
> > much time and effort to complete this change to our design we
> > re-submitted the driver only to receive a response suggesting that
we
> > change once again from this interface to a different API interface
> > called rtnl_link.  Needless to say I am very frustrated with this
> > process. This new API interface would require substantial changes to
> > our code.
> 
> Thats one of the reasons why it should be done before merging it.
> The other one being that an API can't be removed easily once its
> in the kernel.


