From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 2/3] openvswitch: fix struct geneve_port member
 name
Date: Sun, 10 Jan 2016 11:21:03 +0100
Message-ID: <20160110102103.GB1190@pox.localdomain>
References: <1452380831-11258-3-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Pravin Shelar <pshelar@nicira.com>,
	dev@openvswitch.org
To: J??an Sacren <sakiwit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:35166 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbcAJKVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 05:21:07 -0500
Received: by mail-wm0-f44.google.com with SMTP id f206so180164667wmf.0
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 02:21:05 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1452380831-11258-3-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/09/16 at 04:07pm, J??an Sacren wrote:
> From: Jean Sacren <sakiwit@gmail.com>
> 
> commit 6b001e682e90 ("openvswitch: Use Geneve device.")
> 
> The commit above introduced 'port_no' as the name for the member of
> struct geneve_port. The correct name should be 'dst_port' as described
> in the kernel doc. Let's fix that member name and all the pertinent
> instances so that both doc and code would be consistent.
> 
> Signed-off-by: Jean Sacren <sakiwit@gmail.com>

LGTM, also in line with VXLAN.

Acked-by: Thomas Graf <tgraf@suug.ch>
