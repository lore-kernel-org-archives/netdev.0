From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2] Makefile: really suppress printing of
 directories
Date: Fri, 9 Dec 2016 14:05:15 -0800
Message-ID: <6270627f-f52c-6c65-6930-2acc69acb525@cumulusnetworks.com>
References: <1481144109-11116-1-git-send-email-dsa@cumulusnetworks.com>
 <20161209125032.57af6e8e@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:35862 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753079AbcLIWFZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 17:05:25 -0500
Received: by mail-pg0-f41.google.com with SMTP id f188so11833562pgc.3
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2016 14:05:25 -0800 (PST)
In-Reply-To: <20161209125032.57af6e8e@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/9/16 12:50 PM, Stephen Hemminger wrote:
> On Wed,  7 Dec 2016 12:55:09 -0800
> David Ahern <dsa@cumulusnetworks.com> wrote:
> 
>> Makefile adds --no-print-directory to MAKEFLAGS if VERBOSE is not
>> defined however Config always defines VERBOSE. Update the check to
>> whether VERBOSE is 0.
>>
>> Fixes: 57bdf8b76451 ("Make builds default to quiet mode")
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> 
> Applied to net-next.
> 
> Patch only works with net-next, please label it next time.
> 

That does not sound right. The patch this one fixes was applied back in May, and Makefile has only had one other commit against it since.

Regardless, I will add the label to git to default to net-next.
