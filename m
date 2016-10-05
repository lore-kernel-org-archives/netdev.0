From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net] Add netdev all_adj_list refcnt propagation to fix
 panic
Date: Wed, 5 Oct 2016 15:32:11 +0900
Message-ID: <7a6213de-643d-727a-ade7-699b1aa164b9@cumulusnetworks.com>
References: <1475523782-6358-1-git-send-email-acollins@cradlepoint.com>
 <20161004.020628.353742496666781216.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vfalico@gmail.com,
        nikolay@cumulusnetworks.com
To: David Miller <davem@davemloft.net>, acollins@cradlepoint.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36484 "EHLO
        mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751393AbcJEGcS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2016 02:32:18 -0400
Received: by mail-pa0-f42.google.com with SMTP id ry6so5538105pac.3
        for <netdev@vger.kernel.org>; Tue, 04 Oct 2016 23:32:18 -0700 (PDT)
In-Reply-To: <20161004.020628.353742496666781216.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/4/16 3:06 PM, David Miller wrote:
> Applied and queued up for -stable, thanks.

While our original problem was fixed by this patch, Roopa found another series of commands where it fails to properly do dev_put so a followup is needed. 
