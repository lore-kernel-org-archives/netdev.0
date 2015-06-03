From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [RFC net-next 0/3] IP imposition of per-nh MPLS encap
Date: Wed, 3 Jun 2015 14:30:22 +0100
Message-ID: <556F016E.6020304@brocade.com>
References: <1433177175-16775-1-git-send-email-rshearma@brocade.com> <20150602000603.GB18435@pox.localdomain> <556DAF9A.9050505@brocade.com> <20150602214324.GB5842@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	roopa <roopa@cumulusnetworks.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:48749 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751980AbbFCNa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 09:30:58 -0400
In-Reply-To: <20150602214324.GB5842@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/06/15 22:43, Thomas Graf wrote:
> On 06/02/15 at 02:28pm, Robert Shearman wrote:
>> Nesting attributes inside the RTA_ENCAP blob should be supported by the
>> patch series today. Something like this:
>
> Sure. I'm not seeing such a construct for the MPLS case yet.

Right, that is something that should probably be done.

> I'm happy to rebase my patches on top of your nexthop implementation.
> It is definitely superior. Are you maintaining a git tree somewhere?

I wasn't, but I am now:

https://github.com/rshearman/linux/tree/mpls-encap
https://github.com/rshearman/iproute2/tree/mpls-encap

Thanks,
Rob
