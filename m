From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] Add support for configuring Infiniband GUIDs
Date: Fri, 6 May 2016 11:53:41 -0700
Message-ID: <20160506115341.5b8d4587@xeon-e3>
References: <1462549405-16003-1-git-send-email-eli@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
To: Eli Cohen <eli@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35743 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756380AbcEFSx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 14:53:29 -0400
Received: by mail-pa0-f45.google.com with SMTP id iv1so50061225pac.2
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 11:53:29 -0700 (PDT)
In-Reply-To: <1462549405-16003-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  6 May 2016 10:43:25 -0500
Eli Cohen <eli@mellanox.com> wrote:

> Add two NLA's that allow configuration of Infiniband node or port GUIDs
> by referencing the IPoIB net device set over then physical function. The
> format to be used is as follows:
> 
> ip link set dev ib0 vf 0 node_guid 00:02:c9:03:00:21:6e:70
> ip link set dev ib0 vf 0 port_guid 00:02:c9:03:00:21:6e:78
> 
> Issue: 702759
> Change-Id: I5ffb54d6de7bfa8650bf5818f484279914991d6e
> Signed-off-by: Eli Cohen <eli@mellanox.com>

I am not that familiar with Infiniband, but the documentation seems
to use a non-colon form:
 # ip link set dev ib0 vf 0 node_guid 0002c90300216e70

Seems like ip should follow the lead of ibstat and friends.
