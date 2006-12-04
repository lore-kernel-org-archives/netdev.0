From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Network virtualization/isolation
Date: Mon, 04 Dec 2006 09:58:04 -0700
Message-ID: <m1k6178uoz.fsf@ebiederm.dsl.xmission.com>
References: <453F8800.9070603@fr.ibm.com> <1165155198.3517.86.camel@localhost>
	<m1y7ppdl50.fsf@ebiederm.dsl.xmission.com>
	<200612041819.01017.dim@openvz.org>
	<20061204164332.GA11687@MAIL.13thfloor.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Mishin <dim@openvz.org>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, hadi@cyberus.ca,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:34762 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937136AbWLDQ6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 11:58:51 -0500
To: Herbert Poetzl <herbert@13thfloor.at>
In-Reply-To: <20061204164332.GA11687@MAIL.13thfloor.at> (Herbert Poetzl's
	message of "Mon, 4 Dec 2006 17:43:32 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Poetzl <herbert@13thfloor.at> writes:

> On Mon, Dec 04, 2006 at 06:19:00PM +0300, Dmitry Mishin wrote:
>> On Sunday 03 December 2006 19:00, Eric W. Biederman wrote:
>> > Ok.  Just a quick summary of where I see the discussion.
>> >
>> > We all agree that L2 isolation is needed at some point.
>
>> As we all agreed on this, may be it is time to send patches
>> one-by-one? For the beggining, I propose to resend Cedric's 
>> empty namespace patch as base for others - it is really empty, 
>> but necessary in order to move further.
>> 
>> After this patch and the following net namespace unshare 
>> patch will be accepted, 
>
> well, I have neither seen any performance tests showing
> that the following is true:
>
>  - no change on network performance without the 
>    space enabled
>  - no change on network performance on the host
>    with the network namespaces enabled
>  - no measureable overhead inside the network
>    namespace 
>  - good scaleability for a larger number of network
>    namespaces 

Yes all important criteria for selecting the implementation.

Eric
