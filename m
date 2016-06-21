From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH 0/2] Check MAC address length when changing it
Date: Tue, 21 Jun 2016 08:52:47 -0700
Message-ID: <20160621085247.39fc11ba@xeon-e3>
References: <1466086780-5613-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:35535 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752020AbcFUQVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 12:21:55 -0400
In-Reply-To: <1466086780-5613-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Jun 2016 16:19:38 +0200
Phil Sutter <phil@nwl.cc> wrote:

> Due to minimal checking in kernel space, MAC address setting was
> problematic in multiple ways:
> 
> - Setting an overly long MAC address was accepted and the extra parts
>   simply ignored.
> 
> - Setting an overly short MAC address for VFs was accepted and the
>   missing part filled with random garbage.
> 
> While patch 1 makes sure that in the second case above missing parts are
> padded with zero, patch 2 implements a real solution for both by
> comparing new and old address lengths prior to accepting the input. For
> VFs it is simply assumed that the length must match that of the PF's
> address.
> 
> Phil Sutter (2):
>   iplink: Add missing variable initialization
>   iplink: Check address length via netlink
> 
>  ip/iplink.c | 54 +++++++++++++++++++++++++++++++++++++++++++++++++++---
>  1 file changed, 51 insertions(+), 3 deletions(-)
> 

Sure. Applied
