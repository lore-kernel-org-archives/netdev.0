From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC PATCH] Add bridge ifindex to bridge fdb notify msgs
Date: Tue, 27 May 2014 20:39:23 -0400
Message-ID: <5385303B.80209@mojatatu.com>
References: <1401165586-13836-1-git-send-email-roopa@cumulusnetworks.com> <20140527093713.512824b0@nehalam.linuxnetplumber.net> <5384C5C6.2090606@cumulusnetworks.com> <538508D0.5050405@mojatatu.com> <53850A39.5060406@mojatatu.com> <5385285D.4060106@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	davem@davemloft.net, netdev@vger.kernel.org,
	wkok@cumulusnetworks.com,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:51021 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753489AbaE1Ajb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 20:39:31 -0400
Received: by mail-ie0-f171.google.com with SMTP id to1so9625012ieb.2
        for <netdev@vger.kernel.org>; Tue, 27 May 2014 17:39:31 -0700 (PDT)
In-Reply-To: <5385285D.4060106@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/27/14 20:05, Roopa Prabhu wrote:
> Jamal,
>
> i hadn't looked at NDA_MASTER for set yet.
> I was going to. We have some versions of patches for notify and dump
> which i was mainly focusing on.
> Agree that it is not needed for sets and creates further confusion and
> possibly creates the same problems in userspace which i am trying to
> solve. So, ack on that.
>

Ok.

> I had a question regarding dump,
> We can filter in kernel (as your patch does on the other thread) or in
> userspace based on master index with new filter arguments to iproute2 to
> determine the bridge and port for filtering. This follows the existing
> filtering support in all other cmds in iproute2. Which is great.
>

I was thinking of doing what you did after - if i was able to show
you my handwritten notes, youd see it scribbled ;-> So i am glad
you did.

> But, Is there any interest in adding master to the default iproute2
> bridge output ?. like the below ?
> # bridge fdb show
> 44:38:39:00:27:ba dev bond2.2003 master br-2003 permanent
> 44:38:39:00:27:bb dev bond4.2003 master br-2003 permanent
> 44:38:39:00:27:bc dev bond2.2004 master br-2004 permanent
>
> master can be put at the end of the output line for each fdb entry or
> make it optional with -d[etails].
>
 >
> (Don't intend to change output and break existing apps and i also
> understand that filtering by bridge/master name is a way to solve the
> problem. But i had a request from our internal team to post the
> question. So, just asking to see if there is interest to modify the
> default fdb show to include the master during display. It would make the
> default global fdb show cmd more complete).

I agree that is more complete to just display the bridge as well.
Not sure even -d should be necessary. The bridge command is so new
i am not sure people will scream - but i leave that call to Stephen.

cheers,
jamal

PS:- I will redo my patch on top of yours and use ndm ifindex for
bridge port.
