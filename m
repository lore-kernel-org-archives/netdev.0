From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH 21/51] lib/libnetlink: Don't pass NULL parameter
 to memcpy()
Date: Tue, 15 Aug 2017 08:15:55 -0700
Message-ID: <20170815081555.104dab6e@xeon-e3>
References: <20170812120510.28750-1-phil@nwl.cc>
        <20170812120510.28750-22-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:33047 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751573AbdHOPP6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 11:15:58 -0400
Received: by mail-pg0-f43.google.com with SMTP id u5so7440877pgn.0
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 08:15:58 -0700 (PDT)
In-Reply-To: <20170812120510.28750-22-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 12 Aug 2017 14:04:40 +0200
Phil Sutter <phil@nwl.cc> wrote:

> Both addattr_l() and rta_addattr_l() may be called with NULL data
> pointer and 0 alen parameters. Avoid calling memcpy() in that case.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

What are you fixing. memcpy(dest, NULL, 0) should be harmless NOP
