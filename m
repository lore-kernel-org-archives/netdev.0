From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH 03/51] ipaddress: Make buffer for filter.flushb
 static
Date: Tue, 15 Aug 2017 08:13:08 -0700
Message-ID: <20170815081308.3feb2898@xeon-e3>
References: <20170812120510.28750-1-phil@nwl.cc>
        <20170812120510.28750-4-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:37021 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752542AbdHOPNQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 11:13:16 -0400
Received: by mail-pg0-f51.google.com with SMTP id y129so7273917pgy.4
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 08:13:15 -0700 (PDT)
In-Reply-To: <20170812120510.28750-4-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 12 Aug 2017 14:04:22 +0200
Phil Sutter <phil@nwl.cc> wrote:

> The buffer is accessed outside of the function defining it, so make it
> static.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Where does a function access this buffer which is not a sibling?
