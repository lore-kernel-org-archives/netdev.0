From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 0/5] switchdev: add swdev ops
Date: Sun, 15 Mar 2015 18:03:55 +0100
Message-ID: <20150315170355.GJ2043@nanopsycho.orion>
References: <1426400107-6072-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:32823 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751477AbbCORD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 13:03:59 -0400
Received: by wixw10 with SMTP id w10so17995974wix.0
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 10:03:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1426400107-6072-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Mar 15, 2015 at 07:15:02AM CET, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Per discussions at netconf, move switchdev ndo ops to a new swdev_ops to
>keep ndo namespace clean and maintain switchdev-related ops into one place.
>
>There are no functional changes here; just shuffling ops around for better
>organization.

Hmm, I'm not sure this is the right approach. I think we do not need
only switchdev ops to be pushed out. There are many more ndos that could
be pushed out as well. What I'm thinking about is some more generic ndo
struct partitioning. Have to think about the actual implementation some more.

Jiri

>
>Scott Feldman (5):
>  switchdev: add swdev ops
>  switchdev: use new swdev ops
>  rocker: move to new swdev ops
>  dsa: move to new swdev ops
>  netdev: remove ndo ops for switchdev
>
> drivers/net/ethernet/rocker/rocker.c |   64 +++++++++++++++++++---------------
> include/linux/netdevice.h            |   41 ++--------------------
> include/net/switchdev.h              |   38 ++++++++++++++++++++
> net/dsa/slave.c                      |    8 +++--
> net/switchdev/switchdev.c            |   42 +++++++++++-----------
> 5 files changed, 104 insertions(+), 89 deletions(-)
>
>-- 
>1.7.10.4
>
