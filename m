From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2] netns: avoid directory traversal (was: ip netns:
 Make sure netns name is sane)
Date: Thu, 20 Jul 2017 17:25:21 -0700
Message-ID: <20170720172521.3fd57f26@xeon-e3>
References: <20170718171230.084c804e@xeon-e3>
        <20170719223632.4124-1-mcroce@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>, netdev@vger.kernel.org
To: Matteo Croce <mcroce@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:38610 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965209AbdGUAZY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 20:25:24 -0400
Received: by mail-pg0-f48.google.com with SMTP id s4so21219537pgr.5
        for <netdev@vger.kernel.org>; Thu, 20 Jul 2017 17:25:24 -0700 (PDT)
In-Reply-To: <20170719223632.4124-1-mcroce@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Jul 2017 00:36:32 +0200
Matteo Croce <mcroce@redhat.com> wrote:

> v2: reword commit message
> 
> ip netns keeps track of created namespaces with bind mounts named
> /var/run/netns/<namespace>. No input sanitization is done, allowing creation and
> deletion of files relatives to /var/run/netns or, if the path is non existent or
> invalid, allows to create "untracked" namespaces (invisible to the tool).
> 
> This commit denies creation or deletion of namespaces with names contaning
> "/" or matching exactly "." or "..".
> 
> Signed-off-by: Matteo Croce <mcroce@redhat.com>

Applied. I manually edited the commit description to remove the (was...)
thanks Matteo.
