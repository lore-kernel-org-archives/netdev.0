From: Thomas Graf <tgraf@noironetworks.com>
Subject: Re: [ovs-dev] [RFC: add openvswitch actions using BPF 1/9] hack: Do
 not compile datapath
Date: Thu, 5 Feb 2015 14:44:54 +0100
Message-ID: <20150205134454.GA5546@pox.localdomain>
References: <1423090163-19902-1-git-send-email-azhou@nicira.com>
 <1423090163-19902-2-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.com, netdev@vger.kernel.org
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:49108 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757717AbbBENo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 08:44:58 -0500
Received: by mail-wi0-f171.google.com with SMTP id l15so38926063wiw.4
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 05:44:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1423090163-19902-2-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/04/15 at 02:49pm, Andy Zhou wrote:
> The OVS eBPF patch sets are developed against master 'net-next' tree,
> which is currently targeting for kernel version 3.19.
> 
> The datapath in OVS mater does not currently support 3.19 kernel.
> But we should not really using OVS datapath, The changes in the
> follow patches are only changes in user space programs, which should
> work with the kernel module built from the 'net-next' tree.
> 
> This patch disables building of the datapath and disables the
> configuration time kernel version check.
> 
> Signed-off-by: Andy Zhou <azhou@nicira.com>

You can drop this when the datapath sync series is fully merged.
