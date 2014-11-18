From: Cong Wang <cwang@twopensource.com>
Subject: Re: Question about Patch Submissions
Date: Tue, 18 Nov 2014 12:21:25 -0800
Message-ID: <CAHA+R7P-G4P-AzTM248FqNEm=dcuQOB_fwdM0Us3gsQgSeY0UQ@mail.gmail.com>
References: <546B9A45.9040509@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: rapier <rapier@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f176.google.com ([209.85.216.176]:56750 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754214AbaKRUV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 15:21:26 -0500
Received: by mail-qc0-f176.google.com with SMTP id i17so4878033qcy.35
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 12:21:25 -0800 (PST)
In-Reply-To: <546B9A45.9040509@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 18, 2014 at 11:13 AM, rapier <rapier@psc.edu> wrote:
> I've read the documentation I've been able to find on the patch submission
> process. I was hoping to clarify one thing though. When submitting a patch
> that spans multiple files and functions is it better to break the submission
> down by function or by file?
>

It depends on what you change, if your patch is trivial, say just cleaning up
whitespaces, or a big single patch doesn't harm review, it is okay not
to split it.
Otherwise, probably you need to split it logically, each of which needs to at
least compile.
