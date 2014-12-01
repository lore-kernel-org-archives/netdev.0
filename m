From: Jesse Gross <jesse@nicira.com>
Subject: Re: ovs datapath complains on unexpected mask for netlink commands
Date: Mon, 1 Dec 2014 15:39:58 -0800
Message-ID: <CAEP_g=-g7hH2NtOzdzRMiv+1onk74e0Tny8H0v7zHoqqTvog7Q@mail.gmail.com>
References: <54775D61.6090300@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <ogerlitz@mellanox.com>,
	Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog101.obsmtp.com ([74.125.149.67]:50518 "HELO
	na3sys009aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932516AbaLAXkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2014 18:40:19 -0500
Received: by mail-qc0-f181.google.com with SMTP id m20so8459687qcx.40
        for <netdev@vger.kernel.org>; Mon, 01 Dec 2014 15:40:18 -0800 (PST)
In-Reply-To: <54775D61.6090300@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 27, 2014 at 9:20 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> Hi Jesse,
>
> I am running with net-next as of commit 2ad7bf36 "ipvlan: Initial check-in
> [...]"
> and user-space OVS v2.0.90 built from the upstream git.
>
> I suddenly realized that my kernel logs gets filled with the below
> prints which effectively take place for each ovs-vsctl command I run...
>
> openvswitch: netlink: Unexpected mask (mask=1205c, allowed=19805c)
> openvswitch: netlink: Unexpected mask (mask=1205c, allowed=19805c)
> openvswitch: netlink: Unexpected mask (mask=1205c, allowed=19805c)
> openvswitch: netlink: Unexpected mask (mask=1205c, allowed=19805c)
> openvswitch: netlink: Unexpected mask (mask=1205c, allowed=19805c)

Thanks I see the problem. It looks like Pravin just sent out a patch
to fix this issue last night - "[PATCH net] openvswitch: Fix flow mask
validation.".
