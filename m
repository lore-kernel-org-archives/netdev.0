From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][NET_SCHED] sch_api: fix qdisc_tree_decrease_qlen() loop
Date: Tue, 15 Apr 2008 13:00:45 +0000
Message-ID: <20080415130045.GB4993@ff.dom.local>
References: <20080413121031.GA5211@ami.dom.local> <20080414202605.GA6164@ami.dom.local> <4803BE84.4040105@trash.net> <20080414.151102.169978802.davem@davemloft.net> <20080415053253.GA3920@ff.dom.local> <4804A18C.2060200@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, enrico@superclick.com,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:61095 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753637AbYDOM6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 08:58:37 -0400
Received: by yw-out-2324.google.com with SMTP id 5so983071ywb.1
        for <netdev@vger.kernel.org>; Tue, 15 Apr 2008 05:58:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4804A18C.2060200@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 15, 2008 at 02:37:32PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> On Mon, Apr 14, 2008 at 03:11:02PM -0700, David Miller wrote:
>> ...
>>>> Jarek Poplawski wrote:
>> ...
>>>>> After this fix qdisc_lookup() is omitted both for ingress and root
>>>>> parents, but looking for root is only wasting a little time here...
>>
>> ...Actually, there is yet a possibility that somebody uses ffff:
>> handle for a qdisc (not ingress), which could make here a little
>> difference, so this place could be improved for this case (even
>> with something like my earlier debugging patch in this thread,
>> which BTW could be a safety for maybe some other quirks here),
>> but it seems it would be better to discourage using this handle
>> for anything but ingress.
>
>
> I don't think we should do that, it would be preferable to
> compare the entire handle instead of just the major to avoid
> this.

Probably you are right... I guess you could handle this?

Regards,
Jarek P.
