From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [patch net-next] tc: add BPF based action
Date: Wed, 07 Jan 2015 19:33:39 +0100
Message-ID: <54AD7C03.3010904@redhat.com>
References: <1420649035-9522-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
	stephen@networkplumber.org, ast@plumgrid.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34846 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753573AbbAGSdv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2015 13:33:51 -0500
In-Reply-To: <1420649035-9522-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/2015 05:43 PM, Jiri Pirko wrote:
> This action provides a possibility to exec custom BPF code.

Can you elaborate a bit more on the particular use-case, and
what scenarios are unsolveable with the BPF filter we already
have in tc? Just wondering, since you're using BPF for the
purpose of classifying (but just from the context of actions)
what about a possibility of a generic container for reusing
(any) classifier from the framework, so we would not need to
duplicate code?

On the other hand, I would understand if it's at some point in
time eBPF which would f.e. mangle the packet, but the API you
propose is clearly classic BPF. ;)

Thanks,
Daniel
