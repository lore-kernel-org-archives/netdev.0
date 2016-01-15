From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net v2] ovs: add recursion limit to ovs_vport_receive
Date: Fri, 15 Jan 2016 14:28:29 +0900
Message-ID: <20160115052825.GA20879@vergenet.net>
References: <1452812755-14018-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Pravin Shelar <pshelar@ovn.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34485 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810AbcAOF2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2016 00:28:38 -0500
Received: by mail-pa0-f50.google.com with SMTP id uo6so373748408pac.1
        for <netdev@vger.kernel.org>; Thu, 14 Jan 2016 21:28:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1452812755-14018-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Jan 15, 2016 at 12:05:55AM +0100, Hannes Frederic Sowa wrote:
> It was seen that defective configurations of openvswitch could overwrite
> the STACK_END_MAGIC and cause a hard crash of the kernel because of too
> many recursions within ovs.
> 
> This problem arises due to the high stack usage of openvswitch. The rest
> of the kernel is fine with the current limit of 10 (RECURSION_LIMIT).
> Thus add an extra recursion limit counter for ovs_vport_receive until
> parts of the stack usage is moved to percpu scratch space.
> 
> Cc: Pravin Shelar <pshelar@ovn.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks for this. Its looks like a clean solution to a problem
that has been on my todo list for quite some time.

Reviewed-by: Simon Horman <simon.horman@netronome.com>
