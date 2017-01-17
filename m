From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net] lwtunnel: fix autoload of lwt modules
Date: Tue, 17 Jan 2017 11:04:35 -0700
Message-ID: <54cf1176-5131-c0a0-572e-47feda7e07a9@cumulusnetworks.com>
References: <1484631185-9428-1-git-send-email-dsa@cumulusnetworks.com>
 <e6637ef9-02e4-bbfc-b5f0-bdd7c560714e@brocade.com>
 <8b621810-f7b3-05bb-413b-29389125c6ea@cumulusnetworks.com>
 <0e226af4-cb62-9b20-f8a2-191b0aaffb11@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Robert Shearman <rshearma@brocade.com>, netdev@vger.kernel.org,
        roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34368 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750830AbdAQSEh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 13:04:37 -0500
Received: by mail-pf0-f177.google.com with SMTP id e4so25273700pfg.1
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 10:04:37 -0800 (PST)
In-Reply-To: <0e226af4-cb62-9b20-f8a2-191b0aaffb11@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/17/17 10:26 AM, Robert Shearman wrote:
> Ok, I'll continue looking too and let you know if there's anything else that pops up.
> 
> Having said that, even if we eliminate all the unreferenced objects in the current code, what are the chances that we'll be able to keep it this way going forward? Perhaps it would be safer to retry the insert operation from as close to the start as possible?

handling restart for all code paths seems a bit risky for 4.10. Perhaps then the best course for 4.10 and older stable releases is to remove the autoload code from lwtunnel. It can be re-added once the recovery path is handled.
