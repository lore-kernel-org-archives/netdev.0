From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next] nstat: add sctp snmp support
Date: Fri, 2 Sep 2016 12:46:49 -0700
Message-ID: <20160902124649.1ead9f4a@xeon-e3>
References: <1472800358-31881-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36257 "EHLO
        mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932340AbcIBTqk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 15:46:40 -0400
Received: by mail-pa0-f53.google.com with SMTP id fu3so35284133pad.3
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 12:46:40 -0700 (PDT)
In-Reply-To: <1472800358-31881-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  2 Sep 2016 15:12:38 +0800
Hangbin Liu <liuhangbin@gmail.com> wrote:

> SCTP module was not load by default. But this should be OK since we will not
> load table if fdopen() failed.
> 
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>

This seems like a bad idea for the normal distro user.
If they run nstat command the SCTP kernel module would get loaded even
if never used.

Makes more sense not to display SCTP statistics if it isn't loaded.
