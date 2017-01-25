From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: ipv6: ignore null_entry on route dumps
Date: Tue, 24 Jan 2017 21:07:24 -0700
Message-ID: <a4e48364-23e5-a7a5-e09a-6e60841088db@cumulusnetworks.com>
References: <20170122.235829.1911961579892347071.davem@davemloft.net>
 <a1eaeddc-69df-e0fa-c06a-285c3234249c@cumulusnetworks.com>
 <95b123db-a760-b73a-a858-9be0516799fc@cumulusnetworks.com>
 <20170124.203932.616922168982477148.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiaolong.ye@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:36723 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751137AbdAYEH1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 23:07:27 -0500
Received: by mail-pg0-f53.google.com with SMTP id 3so2041661pgj.3
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 20:07:26 -0800 (PST)
In-Reply-To: <20170124.203932.616922168982477148.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/24/17 6:39 PM, David Miller wrote:
> Although, it's troubling that we are trying to dump unfinished entries
> simply because of initialization order.  It's arguable that this is
> the real thing to fix.

that's rabbit hole from which I have not found an exit
