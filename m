From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] tc: add BPF based action
Date: Thu, 8 Jan 2015 08:26:00 +0100
Message-ID: <20150108072600.GC1860@nanopsycho.orion>
References: <1420649035-9522-1-git-send-email-jiri@resnulli.us>
 <54AD7C03.3010904@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
	stephen@networkplumber.org, ast@plumgrid.com
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:49770 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751298AbbAHH0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 02:26:03 -0500
Received: by mail-wi0-f174.google.com with SMTP id h11so1368997wiw.1
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 23:26:01 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54AD7C03.3010904@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jan 07, 2015 at 07:33:39PM CET, dborkman@redhat.com wrote:
>On 01/07/2015 05:43 PM, Jiri Pirko wrote:
>>This action provides a possibility to exec custom BPF code.
>
>Can you elaborate a bit more on the particular use-case, and
>what scenarios are unsolveable with the BPF filter we already
>have in tc? Just wondering, since you're using BPF for the
>purpose of classifying (but just from the context of actions)
>what about a possibility of a generic container for reusing
>(any) classifier from the framework, so we would not need to
>duplicate code?
>
>On the other hand, I would understand if it's at some point in
>time eBPF which would f.e. mangle the packet, but the API you
>propose is clearly classic BPF. ;)

Exactly. I would like to extend cls_bpf and act_bpf to handle eBPF right
after. That is the point.

>
>Thanks,
>Daniel
