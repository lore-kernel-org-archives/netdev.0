From: Eli Cohen <eli@mellanox.com>
Subject: RE: [PATCH] Add support for configuring Infiniband GUIDs
Date: Mon, 9 May 2016 15:52:02 +0000
Message-ID: <DB5PR05MB1848F2481D0767935CA14399C5700@DB5PR05MB1848.eurprd05.prod.outlook.com>
References: <1462549405-16003-1-git-send-email-eli@mellanox.com>
 <20160506115341.5b8d4587@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "shemminger@osdl.org" <shemminger@osdl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eli Cohen (eli@dev.mellanox.co.il)" <eli@dev.mellanox.co.il>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0087.outbound.protection.outlook.com ([157.56.112.87]:43296
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751150AbcEIPwH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 11:52:07 -0400
In-Reply-To: <20160506115341.5b8d4587@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

ibstat is usually used with MLNX_OFED distributions and I don't think it is a part of libibverbs.
Moreover, in a previous patch I sent https://patchwork.ozlabs.org/patch/596492/ I documented in the change log the same format I mention in this patch. So if I change the format here we will have the changelog in the kernel tree invalid.

How do you think this should be addressed?

-----Original Message-----
From: Stephen Hemminger [mailto:stephen@networkplumber.org] 
Sent: Friday, May 06, 2016 1:54 PM
To: Eli Cohen <eli@mellanox.com>
Cc: shemminger@osdl.org; netdev@vger.kernel.org
Subject: Re: [PATCH] Add support for configuring Infiniband GUIDs

On Fri,  6 May 2016 10:43:25 -0500
Eli Cohen <eli@mellanox.com> wrote:

> Add two NLA's that allow configuration of Infiniband node or port 
> GUIDs by referencing the IPoIB net device set over then physical 
> function. The format to be used is as follows:
> 
> ip link set dev ib0 vf 0 node_guid 00:02:c9:03:00:21:6e:70 ip link set 
> dev ib0 vf 0 port_guid 00:02:c9:03:00:21:6e:78
> 
> Issue: 702759
> Change-Id: I5ffb54d6de7bfa8650bf5818f484279914991d6e
> Signed-off-by: Eli Cohen <eli@mellanox.com>

I am not that familiar with Infiniband, but the documentation seems to use a non-colon form:
 # ip link set dev ib0 vf 0 node_guid 0002c90300216e70

Seems like ip should follow the lead of ibstat and friends.
