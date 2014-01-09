From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 05/15] i40e: add a comment on barrier and fix panic
 on reset
Date: Thu, 09 Jan 2014 18:42:00 +0400
Message-ID: <52CEB538.50505@cogentembedded.com>
References: <1389271944-26227-1-git-send-email-jeffrey.t.kirsher@intel.com> <1389271944-26227-6-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:40513 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060AbaAIOl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 09:41:57 -0500
Received: by mail-lb0-f176.google.com with SMTP id l4so2398849lbv.35
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 06:41:56 -0800 (PST)
In-Reply-To: <1389271944-26227-6-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09-01-2014 16:52, Jeff Kirsher wrote:

> From: Greg Rose <gregory.v.rose@intel.com>

> The memory barrier used in maybe_stop_tx can use a comment.

> Also add checks to VSI->rx_rings to ensure a kernel panic is not induced.

    Don't see why this is made in one patch instead of two since the two 
things look completely unrelated and even modifying different files.

> Change-ID: I48cc1bf1d6cf301818155b737edeef77c0d790c7
> Change-ID: I1363a8445fbf521a26267849966296ed55f43ad8

    Why even 2 of them?

> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

WBR, Sergei
