From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH RFC net-next 0/4] bridge: improve cache utilization
Date: Tue, 31 Jan 2017 17:41:19 +0100
Message-ID: <31c4c454-b0e5-5a84-ffce-c8b39fa2d301@cumulusnetworks.com>
References: <1485876718-18091-1-git-send-email-nikolay@cumulusnetworks.com>
 <20170131083919.51a3ac9f@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        davem@davemloft.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:36311 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751090AbdAaQlV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 11:41:21 -0500
Received: by mail-wm0-f44.google.com with SMTP id c85so268664628wmi.1
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 08:41:21 -0800 (PST)
In-Reply-To: <20170131083919.51a3ac9f@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> I agree with the first 3 patches, but not the last one.
> Changing the API just for a performance hack is not necessary. Instead make
> the algorithm smarter and use per-cpu values.
> 

Thanks for the feedback, I would very much prefer any of the other two approaches
I tried (per-cpu pool and per-cpu for each fdb), from the two the second one -
per-cpu for each fdb is much simpler, so would it be acceptable to do per-cpu allocation
for each fdb ?
