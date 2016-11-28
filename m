From: =?gb2312?B?1cXKpL7Z?= <zhangshengju@cmss.chinamobile.com>
Subject: RE: [net,v2] neigh: fix the loop index error in neigh dump
Date: Mon, 28 Nov 2016 10:53:25 +0800
Message-ID: <001d01d24922$9a16b1e0$ce4415a0$@cmss.chinamobile.com>
References: <1480296725-5563-1-git-send-email-zhangshengju@cmss.chinamobile.com> <caa11887-00b9-d2f1-7c0b-5b5096b42f56@cumulusnetworks.com> <001c01d2491f$fcd53250$f67f96f0$@cmss.chinamobile.com> <6d1a324e-e29e-e2dd-a6fc-1e9b4455cb3d@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="gb2312"
Content-Transfer-Encoding: 8BIT
To: "'David Ahern'" <dsa@cumulusnetworks.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:14225 "EHLO
        cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753640AbcK1CyS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 21:54:18 -0500
In-Reply-To: <6d1a324e-e29e-e2dd-a6fc-1e9b4455cb3d@cumulusnetworks.com>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Ahern [mailto:dsa@cumulusnetworks.com]
> Sent: Monday, November 28, 2016 10:39 AM
> To: 张胜举 <zhangshengju@cmss.chinamobile.com>;
> netdev@vger.kernel.org
> Subject: Re: [net,v2] neigh: fix the loop index error in neigh dump
> 
> On 11/27/16 7:34 PM, 张胜举 wrote:
> >> -----Original Message-----
> >> From: David Ahern [mailto:dsa@cumulusnetworks.com]
> >> Sent: Monday, November 28, 2016 10:10 AM
> >> To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>;
> >> netdev@vger.kernel.org
> >> Subject: Re: [net,v2] neigh: fix the loop index error in neigh dump
> >>
> >> On 11/27/16 6:32 PM, Zhang Shengju wrote:
> >>> Loop index in neigh dump function is not updated correctly under
> >>> some circumstances, this patch will fix it.
> >>
> >> What's an example?
> >
> > If dev is filtered out, the original code goes to next loop without
> > updating loop index 'idx'.
> 
> And you have a use case with missing or redundant data? Or is your
> comment based on a review of code only?
It's on my code review. No use case currently,  this is uncommon to happen.


> 
> >> You are completely rewriting the dump loops.
> >
> > I put 'idx++' into for loop,  so I replace 'goto' with 'continue'.
> > The other change is style related.
> 
> A "fixes" should not include 'style related' changes.
Okay, I will send another version without style changes.
