From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [PATCH net-next] iproute2: MPLS support
Date: Tue, 24 Mar 2015 15:36:09 -0700
Message-ID: <20150324153609.72e3ca93@urahara>
References: <87bnjwspek.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:51573 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751915AbbCXWgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 18:36:09 -0400
In-Reply-To: <87bnjwspek.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Mar 2015 13:50:11 -0500
ebiederm@xmission.com (Eric W. Biederman) wrote:

> This set of changes  adds support for nexthops in different
> address families, with the new netlink RTA_VIA option.
> 
> Support is added for routes that change the destination address (as MPLS
> does) with the RTA_NEWDST attribute.
> 
> Support for MPLS addresses is added (for multiple labels I
> had to make up the syntax I used label/label/label as it fits in
> well with addresses that don't have a space in them).
> 
> Support for these options is merged into David's net-next kernel
> tree, and the meaning of the options is unlikely to change in any
> significant way before this code merges upstream.
> 
> The documentation has been updated to report that the new options
> are present and to report roughly what they do.  This includes
> ip --help and the man pages.
> 
> Eric W. Biederman (8):
>       iproute2: Add a source addres length parameter to rt_addr_n2a
>       iproute2: Make the addr argument of ll_addr_n2a const
>       iproute2: Add support for printing AF_PACKET addresses
>       iproute2: Add address family to/from string helper functions.
>       iproute2: misc whitespace cleanup
>       iproute2: Add support for  RTA_VIA attributes
>       iproute2: Add support for the RTA_NEWDST attribute.
>       iproute2: Add basic mpls support to iproute

Applied to net-next branch of iproute.
Only change was to use result of kernel make headers_install
version of mpls.h
