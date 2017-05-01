From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next iproute2] ip: increase number of MPLS labels
Date: Mon, 1 May 2017 09:15:40 -0700
Message-ID: <20170501091540.13f57676@xeon-e3>
References: <1493524130-10220-1-git-send-email-dsa@cumulusnetworks.com>
        <20170429230430.702c6b72@xeon-e3>
        <ddb54ca8-d7df-3446-3929-5f0116286c80@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        roopa <roopa@cumulusnetworks.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33536 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758473AbdEAQPo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 12:15:44 -0400
Received: by mail-pf0-f180.google.com with SMTP id q20so22744116pfg.0
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 09:15:44 -0700 (PDT)
In-Reply-To: <ddb54ca8-d7df-3446-3929-5f0116286c80@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 30 Apr 2017 17:42:15 -0600
David Ahern <dsa@cumulusnetworks.com> wrote:

> On 4/30/17 12:04 AM, Stephen Hemminger wrote:
> > On Sat, 29 Apr 2017 20:48:50 -0700
> > David Ahern <dsa@cumulusnetworks.com> wrote:
> >   
> >> Kernel now supports more than 2 labels. Increase ip to
> >> handle up to 16 labels.
> >>
> >> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> >> ---
> >>  include/utils.h | 8 ++++----
> >>  lib/utils.c     | 2 +-
> >>  2 files changed, 5 insertions(+), 5 deletions(-)
> >>
> >> diff --git a/include/utils.h b/include/utils.h
> >> index 8c12e1e2a60c..a69e176c260d 100644
> >> --- a/include/utils.h
> >> +++ b/include/utils.h
> >> @@ -54,6 +54,9 @@ void incomplete_command(void) __attribute__((noreturn));
> >>  #define NEXT_ARG_FWD() do { argv++; argc--; } while(0)
> >>  #define PREV_ARG() do { argv--; argc++; } while(0)
> >>  
> >> +/* Maximum number of labels the mpls helpers support */
> >> +#define MPLS_MAX_LABELS 16
> >> +  
> > 
> > Why is the kernel limit not in include/uapi/ header file?
> >   
> 
> I believe Eric had reasons, but not sure why.

I just don't want iproute2 utilities chasing kernel values.
Would prefer either make utilities take any size, or inherit maximum from kernel headers.
