From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: kernel panic in qdisc_match_from_root starting openvswitch
Date: Tue, 16 Aug 2016 11:35:50 -0700
Message-ID: <CAM_iQpVdQBQBCExVvcZLP10kgY4t5xA6m=U203Zzv+un0Ud65w@mail.gmail.com>
References: <bfb76544-6d3a-dcd4-9338-72ecfda9f691@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Kosina <jkosina@suse.cz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Simon Horman <simon.horman@netronome.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34839 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822AbcHPStt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 14:49:49 -0400
Received: by mail-it0-f66.google.com with SMTP id f6so6163054ith.2
        for <netdev@vger.kernel.org>; Tue, 16 Aug 2016 11:49:48 -0700 (PDT)
In-Reply-To: <bfb76544-6d3a-dcd4-9338-72ecfda9f691@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 16, 2016 at 11:27 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
> Jiri:
>
> I am hitting a kernel panic with '/etc/init.d/openvswitch-switch restart' Stack trace below. Reverting 59cc1f61f09c ("net: sched: convert qdisc linked list to hashtable") clears the problem.
>

Jiri is working on it:
https://patchwork.ozlabs.org/patch/659633/
