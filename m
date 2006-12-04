From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: Network virtualization/isolation
Date: Mon, 04 Dec 2006 18:41:33 +0100
Message-ID: <45745DCD.8080308@fr.ibm.com>
References: <453F8800.9070603@fr.ibm.com> <200612041819.01017.dim@openvz.org>	<20061204164332.GA11687@MAIL.13thfloor.at> <200612042002.49094.dim@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Poetzl <herbert@13thfloor.at>,
	Linux Containers <containers@lists.osdl.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, hadi@cyberus.ca,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:33883 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758986AbWLDRmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 12:42:04 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id kB4Hg3pl082122
	for <netdev@vger.kernel.org>; Mon, 4 Dec 2006 17:42:03 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB4Hg2pa2932744
	for <netdev@vger.kernel.org>; Mon, 4 Dec 2006 18:42:02 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB4Hg1bt013996
	for <netdev@vger.kernel.org>; Mon, 4 Dec 2006 18:42:02 +0100
To: Dmitry Mishin <dim@openvz.org>
In-Reply-To: <200612042002.49094.dim@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dmitry Mishin wrote:
> On Monday 04 December 2006 19:43, Herbert Poetzl wrote:
>> On Mon, Dec 04, 2006 at 06:19:00PM +0300, Dmitry Mishin wrote:
>>> On Sunday 03 December 2006 19:00, Eric W. Biederman wrote:
>>>> Ok.  Just a quick summary of where I see the discussion.
>>>>
>>>> We all agree that L2 isolation is needed at some point.
>>> As we all agreed on this, may be it is time to send patches
>>> one-by-one? For the beggining, I propose to resend Cedric's
>>> empty namespace patch as base for others - it is really empty,
>>> but necessary in order to move further.
>>>
>>> After this patch and the following net namespace unshare
>>> patch will be accepted,
>> well, I have neither seen any performance tests showing
>> that the following is true:
>>
>>  - no change on network performance without the
>>    space enabled
>>  - no change on network performance on the host
>>    with the network namespaces enabled
>>  - no measureable overhead inside the network
>>    namespace
>>  - good scaleability for a larger number of network
>>    namespaces
> These questions are for complete L2 implementation, not for these 2 empty 
> patches. If you need some data relating to Andrey's implementation, I'll get 
> it. Which test do you accept?

tbench ?

With the following scenarii:

  * intra host communication (one time with IP on eth and one time with 
127.0.0.1)
  * inter host communication

Each time:
	- a single network namespace
	- with 100 network namespace. 1 server communicating and 99 listening 
but doing nothing.


