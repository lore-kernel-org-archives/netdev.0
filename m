From: rapier <rapier@psc.edu>
Subject: Re: Question about Patch Submissions
Date: Wed, 19 Nov 2014 16:29:24 -0500
Message-ID: <546D0BB4.4030409@psc.edu>
References: <546B9A45.9040509@psc.edu>	<CAHA+R7P-G4P-AzTM248FqNEm=dcuQOB_fwdM0Us3gsQgSeY0UQ@mail.gmail.com>	<546BAE75.7080802@psc.edu> <CAADnVQ+1_Ct3hhmZrCqpxcT=-XS4OXrpRbrHHHyOKQOuoDc06g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <cwang@twopensource.com>, netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:41268 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932991AbaKSV30 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2014 16:29:26 -0500
In-Reply-To: <CAADnVQ+1_Ct3hhmZrCqpxcT=-XS4OXrpRbrHHHyOKQOuoDc06g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/18/14, 8:38 PM, Alexei Starovoitov wrote:
> On Tue, Nov 18, 2014 at 12:39 PM, rapier <rapier@psc.edu> wrote:
>> break this down for presentation. We can make sure each section of the patch
>> applies cleanly but the entirety of the patch set would have to be applied
>> for it to compile.
>
> all patches need to compile cleanly on all architectures,
> otherwise bisect will be broken.

The issue is that this is large patch set. The diff comes in at around 
2200 lines and adds new functionality to the kernel by implementing RFC 
4898. What I'm really trying to figure out is how to split up the diff 
files so I'm not dropping all 2200 lines into a single email message. 
I'm assuming that's not really how people want to see submissions but if 
I am incorrect please let me know.

There are two major components that we should be able to submit as 
distinct patches so that should reduce the line count per submission.

Chris Rapier
