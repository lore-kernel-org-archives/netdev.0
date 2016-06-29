From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 iproute2 0/6] Add support for vrf keyword
Date: Wed, 29 Jun 2016 08:07:40 -0700
Message-ID: <20160629080740.198843fe@xeon-e3>
References: <1467053461-16147-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35705 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752432AbcF2PQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 11:16:10 -0400
Received: by mail-pa0-f53.google.com with SMTP id hl6so18443409pac.2
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 08:14:55 -0700 (PDT)
In-Reply-To: <1467053461-16147-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Jun 2016 11:50:55 -0700
David Ahern <dsa@cumulusnetworks.com> wrote:

> Currently the syntax for VRF related commands is rather kludgy and
> inconsistent from one subcommand to another. This set adds support
> for the VRF keyword to the link, address, neigh, and route commands
> to improve the user experience listing data associated with vrfs,
> modifying routes or doing a route lookup.
> 
> v2
> - rebased to top of tree
> - all checkpatch warnings are usage lines. The change in these
>   patches is consistent with existing code for usage lines

Does this break current user scripts?

It seems this method will cause lots of additional netlink requests
to check if device is a vrf. Won't this impact users with 1000's of devices?
