From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Fwd: [ofa-general] FW: QLogic vNIC Kernel Submission
Date: Tue, 17 Jun 2008 19:59:08 -0400
Message-ID: <48584FCC.4060800@garzik.org>
References: <99863D2ED484D449811D97A4C44C9CBD7C50F7@EPEXCH2.qlogic.org><c8028d330806171018j7f129ddft3bee056e4be9b954@mail.gmail.com><485803D3.5020505@trash.net> <20080617121441.4b87ba84@extreme> <C07C40DB2364324799506DE8FF12F8D859E90D@EPEXCH1.qlogic.org> <99863D2ED484D449811D97A4C44C9CBD7C5169@EPEXCH2.qlogic.org> <48582340.7010409@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Russo <john.russo@qlogic.com>, shemminger@vyatta.com,
	"Amar Mudrankit (Contractor - )" <amar.mudrankit@qlogic.com>,
	netdev@vger.kernel.org, rdreier@cisco.com,
	"Kuchimanchi, Ramachandra \(Contractor - \)"
	<ramachandra.kuchimanchi@qlogic.com>,
	"Poornima Kamath (Contractor - )" <poornima.kamath@qlogic.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33790 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755127AbYFQX7O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 19:59:14 -0400
In-Reply-To: <48582340.7010409@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Frankly, you didn't even try to fix the most obvious mistakes in your
> interface, like duplication of existing interfaces (csum settings)
> and very unusual behaviour (state machine triggered device registation)
> before you started complaining (and both of these are *really* easy to
> do).
> 
> That you were asked to migrate to sysfs is unfortunate. The fact is
> though that your driver is a virtual ethernet device, not an infiniband
> device, so it should use the proper APIs for this kind of device. Work
> has been going on for years to provide a uniform interface to the network
> and your interface is a move in the opposite direction.

That's pretty much my feeling.

	Jeff



