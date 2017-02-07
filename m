From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH 1/2] testsuite: skip link show test on big
 endian systems
Date: Tue, 7 Feb 2017 15:12:49 -0800
Message-ID: <20170207151249.19de5192@xeon-e3>
References: <20170207230422.31936-1-phil@nwl.cc>
        <20170207230422.31936-2-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34325 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755382AbdBGXM5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 18:12:57 -0500
Received: by mail-pf0-f179.google.com with SMTP id e4so36489608pfg.1
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 15:12:57 -0800 (PST)
In-Reply-To: <20170207230422.31936-2-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  8 Feb 2017 00:04:21 +0100
Phil Sutter <phil@nwl.cc> wrote:

> Netlink protocol is in host byte order, so the provided binary netlink
> message buffer being in little endian format will cause the test to fail
> on big endian systems.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Maybe better to figure out how to generate the files in host order?
