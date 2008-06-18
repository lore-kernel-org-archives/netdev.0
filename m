From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Fwd: [ofa-general] FW: QLogic vNIC Kernel Submission
Date: Wed, 18 Jun 2008 06:43:46 -0400
Message-ID: <4858E6E2.8050609@garzik.org>
References: <99863D2ED484D449811D97A4C44C9CBD7C50F7@EPEXCH2.qlogic.org> <c8028d330806171018j7f129ddft3bee056e4be9b954@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com,
	Ramachandra K <ramachandra.kuchimanchi@qlogic.com>,
	poornima.kamath@qlogic.com
To: Amar Mudrankit <amar.mudrankit@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42449 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751084AbYFRKnv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2008 06:43:51 -0400
In-Reply-To: <c8028d330806171018j7f129ddft3bee056e4be9b954@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Amar Mudrankit wrote:
> ---------- Forwarded message ----------
> From: John Russo <john.russo@qlogic.com>
> Date: Tue, Jun 17, 2008 at 6:36 PM
> Subject: [ofa-general] FW: QLogic vNIC Kernel Submission
> To: general@lists.openfabrics.org
> 
> 
> It looks as if my original email was "scrubbed" before it made the
> mailing list so I am resending it...
> 
> QLogic has been attempting to submit our virtual NIC (vNIC) driver to
> the Linux kernel for several months.  We have made changes to the code
> based on the feedback we have received over four rounds of
> submissions. Among the feedback we received during this process was a
> request to alter our code to use a single value per file for
> configuration of our driver through sysfs interface.  After spending
> much time and effort to complete this change to our design we
> re-submitted the driver only to receive a response suggesting that we
> change once again from this interface to a different API interface
> called rtnl_link.  Needless to say I am very frustrated with this
> process. This new API interface would require substantial changes to
> our code.
> 
> QLogic has met the initial request to move to a single valued sysfs
> interface and I would hope that this new request will be waived and
> will not be a roadblock to inclusion of our driver to the kernel.

One option is to get the base driver into the tree, sans sysfs 
interface, and wait for the netlink interface.

As Patrick noted, it is very important to -not- just throw new user 
interfaces into the tree, because that essentially sets them in stone at 
that point, needing to be supported as an Application Binary Interface 
(ABI).

The other stuff, like duplication of existing interfaces and strange 
FSM-based netdev registration, are problems that could be worked out 
in-tree, I suppose.

	Jeff



