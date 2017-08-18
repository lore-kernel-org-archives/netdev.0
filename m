From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v2 2/5] nstat: Fix for potential NULL pointer
 dereference
Date: Fri, 18 Aug 2017 09:28:28 -0700
Message-ID: <20170818092828.74ddf749@xeon-e3>
References: <20170817170931.24545-1-phil@nwl.cc>
        <20170817170931.24545-3-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:36445 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752202AbdHRQ2f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 12:28:35 -0400
Received: by mail-pg0-f48.google.com with SMTP id i12so67502137pgr.3
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 09:28:35 -0700 (PDT)
In-Reply-To: <20170817170931.24545-3-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Aug 2017 19:09:28 +0200
Phil Sutter <phil@nwl.cc> wrote:

> If the string at 'p' contains neither space not newline, 'p' will become
> NULL. Make sure this isn't the case before dereferencing it.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Why not fix the parsing code instead. Other places here call abort().
