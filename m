From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 0/4] ss: Get netlink sockets info via sock-diag (v2)
Date: Wed, 5 Jun 2013 08:56:26 -0700
Message-ID: <20130605085626.5dd9191d@nehalam.linuxnetplumber.net>
References: <1370421721-30814-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrey Vagin <avagin@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:36227 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756666Ab3FEP4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 11:56:30 -0400
Received: by mail-pd0-f175.google.com with SMTP id 4so2014157pdd.6
        for <netdev@vger.kernel.org>; Wed, 05 Jun 2013 08:56:30 -0700 (PDT)
In-Reply-To: <1370421721-30814-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  5 Jun 2013 12:41:57 +0400
Andrey Vagin <avagin@openvz.org> wrote:

> On Thu, Mar 21, 2013 at 10:00:25AM -0700, Stephen Hemminger wrote:
> > Since this depends on functionality not in the upstream kernel.
> > Resubmit this during the 3.10 merge window. At the start of the merge
> > window, headers are synchronized with the kernel headers.
> 
> Netlink socket diag is in the upstream kernel since 3.10-rc1.
> 
> v2: Update kernel headers
> 
> Andrey Vagin (4):
>   ss: handle socket diag request in a separate function
>   ss: create a function to print info about netlink sockets
>   ss: show destination address for netlink sockets
>   ss: Get netlink sockets info via sock-diag (v2)
> 
>  include/linux/netlink_diag.h |  52 ++++++++++
>  misc/ss.c                    | 242 +++++++++++++++++++++++++++++--------------
>  2 files changed, 216 insertions(+), 78 deletions(-)
>  create mode 100644 include/linux/netlink_diag.h
> 


Applied
