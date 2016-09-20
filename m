From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH] tc: don't accept qdisc 'handle' greater than
 ffff
Date: Tue, 20 Sep 2016 09:46:14 -0700
Message-ID: <20160920094614.7d40ed74@xeon-e3>
References: <bdc0d8e58be9344b44fcd64a56b5b62004c108a1.1473930575.git.dcaratti@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>,
        Hangbin Liu <liuhangbin@gmail.com>
To: Davide Caratti <dcaratti@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33001 "EHLO
        mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754132AbcITQwX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 12:52:23 -0400
Received: by mail-pa0-f47.google.com with SMTP id hm5so8812113pac.0
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 09:52:23 -0700 (PDT)
In-Reply-To: <bdc0d8e58be9344b44fcd64a56b5b62004c108a1.1473930575.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 Sep 2016 10:30:00 +0200
Davide Caratti <dcaratti@redhat.com> wrote:

> since get_qdisc_handle() truncates the input value to 16 bit, return an
> error and prompt "invalid qdisc ID" in case input 'handle' parameter needs
> more than 16 bit to be stored.
> 
> Signed-off-by: Davide Caratti <dcaratti@redhat.com>

Applied
