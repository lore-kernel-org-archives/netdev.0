From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net 0/2] vxlan: fix error reporting
Date: Fri, 2 Sep 2016 09:03:11 -0700
Message-ID: <20160902090311.14acb0d1@xeon-e3>
References: <cover.1472815982.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34377 "EHLO
        mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932367AbcIBQDF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 12:03:05 -0400
Received: by mail-pa0-f49.google.com with SMTP id to9so3231306pac.1
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 09:03:04 -0700 (PDT)
In-Reply-To: <cover.1472815982.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  2 Sep 2016 13:37:10 +0200
Jiri Benc <jbenc@redhat.com> wrote:

> This patchset improves checking for invalid configuration in VXLAN and fixes
> problems with duplicated and inappropriate error messages.
> 
> Jiri Benc (2):
>   vxlan: reject multicast destination without an interface
>   vxlan: fix duplicated and wrong error messages
> 
>  drivers/net/vxlan.c | 38 ++++++++++++--------------------------
>  1 file changed, 12 insertions(+), 26 deletions(-)
> 

These should also be detected and rejected in iproute2
errors in kernel log are user unfriendly api.
