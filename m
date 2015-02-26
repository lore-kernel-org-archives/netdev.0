From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/8] Basic MPLS support
Date: Wed, 25 Feb 2015 22:58:37 -0800
Message-ID: <54EEC41D.1010800@cumulusnetworks.com>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	santiago@crfreenet.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:60580 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752752AbbBZG6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 01:58:39 -0500
Received: by mail-ig0-f170.google.com with SMTP id l13so42109205iga.1
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 22:58:39 -0800 (PST)
In-Reply-To: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/25/15, 9:09 AM, Eric W. Biederman wrote:
> While trying to figure out what MPLS is and why MPLS support is not in
> the kernel on a lark I sat down and wrote an MPLS implemenation, so I
> could answer those questions for myself.
>
>  From what I can tell the short answer is MPLS is trivial-simple and the
> we don't have an in-kernel implementation because no one has sat down
> and done the work to have a good mergable implementation.

>
> MPLS has it's good sides and it's bad sides but at the end of the day
> MPLS has users, and having an in-kernel implementation should help us
> understand MPLS and focus our conversations dealing with MPLS and
> VRFs.

very much agree.
>
> Having MPLS in our toolkit as the entire world begins playing with
> overlay networks aka ``network virtualization'' to support VM and
> container migration seems appropriate as MPLS is the historical solution
> to this problem.
>
> Constructive criticism about the netlink interface is especially
> appreciated.  Hopefully we can have at least one protocol in the kernel
> where the netlink interface doesn't have nasty corner case.
>
> As for linux users.  The conversations I had at netdev01 this sounds
> like a case of if I build it people will use the code.
ack again.

Thanks eric!.
