From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fwd: [ofa-general] FW: QLogic vNIC Kernel Submission
Date: Tue, 17 Jun 2008 22:49:04 +0200
Message-ID: <48582340.7010409@trash.net>
References: <99863D2ED484D449811D97A4C44C9CBD7C50F7@EPEXCH2.qlogic.org><c8028d330806171018j7f129ddft3bee056e4be9b954@mail.gmail.com><485803D3.5020505@trash.net> <20080617121441.4b87ba84@extreme> <C07C40DB2364324799506DE8FF12F8D859E90D@EPEXCH1.qlogic.org> <99863D2ED484D449811D97A4C44C9CBD7C5169@EPEXCH2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com,
	"Amar Mudrankit (Contractor - )" <amar.mudrankit@qlogic.com>,
	netdev@vger.kernel.org, rdreier@cisco.com,
	"Kuchimanchi, Ramachandra \(Contractor - \)"
	<ramachandra.kuchimanchi@qlogic.com>,
	"Poornima Kamath (Contractor - )" <poornima.kamath@qlogic.com>
To: John Russo <john.russo@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42358 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755838AbYFQVFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 17:05:09 -0400
In-Reply-To: <99863D2ED484D449811D97A4C44C9CBD7C5169@EPEXCH2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Russo wrote:
>>> As Patrick said, there is also a sense of doing the right thing. The 
>>> developers would rather not repeat past mistakes, so are naturally 
>>> hesitant on API's.
>>>       
>
> I completely understand the sense of doing the right thing. That is why
> we put in the effort to migrate our code to sysfs in the first place.
> We had a different solution but agreed to change it to meet the
> guidelines of other contributors to the InfiniBand (OFED) stack.  What I
> can't understand is the ease of which some people say "let's just change
> to this great new design even if it means a large rewrite of existing
> code which may increase the likelihood of injecting errors".  I
> apologize if I come off as being agitated but it is very frustrating to
> spend time and effort attempting to conform to a groups requests only to
> have it changed at the end. 
>   

Frankly, you didn't even try to fix the most obvious mistakes in your
interface, like duplication of existing interfaces (csum settings)
and very unusual behaviour (state machine triggered device registation)
before you started complaining (and both of these are *really* easy to
do).

That you were asked to migrate to sysfs is unfortunate. The fact is
though that your driver is a virtual ethernet device, not an infiniband
device, so it should use the proper APIs for this kind of device. Work
has been going on for years to provide a uniform interface to the network
and your interface is a move in the opposite direction.


