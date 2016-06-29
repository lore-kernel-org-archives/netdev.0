From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 iproute2 3/3] ss: Add support to filter on device
Date: Tue, 28 Jun 2016 17:11:26 -0700
Message-ID: <20160628171126.5da73f41@xeon-e3>
References: <1467052465-14488-1-git-send-email-dsa@cumulusnetworks.com>
	<1467052465-14488-4-git-send-email-dsa@cumulusnetworks.com>
	<20160627141304.2178a549@xeon-e3>
	<08825943-ee97-c769-e70a-f6dcc3f49493@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34647 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752448AbcF2ALN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 20:11:13 -0400
Received: by mail-pa0-f48.google.com with SMTP id bz2so11106023pad.1
        for <netdev@vger.kernel.org>; Tue, 28 Jun 2016 17:11:13 -0700 (PDT)
In-Reply-To: <08825943-ee97-c769-e70a-f6dcc3f49493@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Jun 2016 11:40:40 -0600
David Ahern <dsa@cumulusnetworks.com> wrote:

> On 6/27/16 3:13 PM, Stephen Hemminger wrote:
> > On Mon, 27 Jun 2016 11:34:25 -0700
> > David Ahern <dsa@cumulusnetworks.com> wrote:
> >  
> >> +		case SSF_DEVCOND:
> >> +	{
> >> +		struct aafilter *a = (void *)f->pred;  
> >
> > I don't like the wandering bracket left, but all the code has that.
> > After this will change it to:
> > 		case SSF_DEVCOND:  {
> > 			struct aafilter *a = f->pred;
> > ...
> >  
> 
> meaning you'll take the patches as is since they follow current 
> formatting and you will apply a patch to fix the indentation in that 
> run_ssfilter? They have not shown up in your repo so want to make sure I 
> understand the intent.

They all got applied today
