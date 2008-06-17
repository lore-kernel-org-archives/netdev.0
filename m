From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Fwd: [ofa-general] FW: QLogic vNIC Kernel Submission
Date: Tue, 17 Jun 2008 12:14:41 -0700
Message-ID: <20080617121441.4b87ba84@extreme>
References: <99863D2ED484D449811D97A4C44C9CBD7C50F7@EPEXCH2.qlogic.org>
	<c8028d330806171018j7f129ddft3bee056e4be9b954@mail.gmail.com>
	<485803D3.5020505@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Amar Mudrankit <amar.mudrankit@qlogic.com>, netdev@vger.kernel.org,
	rdreier@cisco.com,
	Ramachandra K <ramachandra.kuchimanchi@qlogic.com>,
	poornima.kamath@qlogic.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:51595 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755173AbYFQTOr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 15:14:47 -0400
In-Reply-To: <485803D3.5020505@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Jun 2008 20:34:59 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Amar Mudrankit wrote:
> > It looks as if my original email was "scrubbed" before it made the
> > mailing list so I am resending it...
> > 
> > QLogic has been attempting to submit our virtual NIC (vNIC) driver to
> > the Linux kernel for several months.  We have made changes to the code
> > based on the feedback we have received over four rounds of
> > submissions. Among the feedback we received during this process was a
> > request to alter our code to use a single value per file for
> > configuration of our driver through sysfs interface.  After spending
> > much time and effort to complete this change to our design we
> > re-submitted the driver only to receive a response suggesting that we
> > change once again from this interface to a different API interface
> > called rtnl_link.  Needless to say I am very frustrated with this
> > process. This new API interface would require substantial changes to
> > our code.
> 
> Thats one of the reasons why it should be done before merging it.
> The other one being that an API can't be removed easily once its
> in the kernel.

Understand that this is a community process and it isn't going to follow
a corporate model. There is no external pressures like schedules and users.
As Patrick said, there is also a sense of doing the right thing. The developers
would rather not repeat past mistakes, so are naturally hesitant on API's.
Adding a device that follows existing API's is always much easier. What you are
seeing is in part an internal discomfort with the plethora of API's and the binary
baggage of ioctl's, sysfs, etc.

If you could give a general outline of what the interface you want would do,
perhaps the community could provide some sample code that do what you want.
Netlink interfaces are less common, and there are fewer examples.
