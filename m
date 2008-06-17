From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fwd: [ofa-general] FW: QLogic vNIC Kernel Submission
Date: Tue, 17 Jun 2008 20:34:59 +0200
Message-ID: <485803D3.5020505@trash.net>
References: <99863D2ED484D449811D97A4C44C9CBD7C50F7@EPEXCH2.qlogic.org> <c8028d330806171018j7f129ddft3bee056e4be9b954@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com,
	Ramachandra K <ramachandra.kuchimanchi@qlogic.com>,
	poornima.kamath@qlogic.com
To: Amar Mudrankit <amar.mudrankit@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39121 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759389AbYFQSfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 14:35:04 -0400
In-Reply-To: <c8028d330806171018j7f129ddft3bee056e4be9b954@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Amar Mudrankit wrote:
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

Thats one of the reasons why it should be done before merging it.
The other one being that an API can't be removed easily once its
in the kernel.
