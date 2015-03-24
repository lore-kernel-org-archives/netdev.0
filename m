From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2] iproute2: Fix -o (oneline) being broken in xfrm &
 correct mark radix
Date: Tue, 24 Mar 2015 15:02:18 -0700
Message-ID: <20150324150218.42cb176d@urahara>
References: <20150319_195428_022337.philipp@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexy Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Philip Prindeville <philipp@redfish-solutions.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35469 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103AbbCXWCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 18:02:18 -0400
Received: by pagj7 with SMTP id j7so6512904pag.2
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 15:02:18 -0700 (PDT)
In-Reply-To: <20150319_195428_022337.philipp@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Mar 2015 13:54:28 -0600
Philip Prindeville <philipp@redfish-solutions.com> wrote:

> Don't insert newline in -o (oneline) mode; print mark as hex.
> 
> Oneline mode is supposed to force all output to be on oneline and
> machine-parsable, but this isn't the case for "ip xfrm" as shown:
> 
> % ip -o xfrm monitor
> ...
> src 0.0.0.0/0 dst 0.0.0.0/0 \   dir out priority 2051 ptype main \  mark -1879048191/0xffffffff
>     tmpl src 203.0.130.10 dst 198.51.130.30\        proto esp reqid 16384 mode tunnel\
> ...
> 
> as that's 2 lines, not one. Also, the "mark" is shown in signed
> decimal, but the mask is in hex. This is confusing: let's use
> hex for both.
> 
> Signed-off-by: Philip Prindeville <philipp@redfish-solutions.com>

Applied to master. Thanks
