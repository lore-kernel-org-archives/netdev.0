From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: RTM_DELROUTE on interface going down - when to send?
Date: Wed, 18 Dec 2013 10:16:53 +0100
Message-ID: <52B16805.2010601@6wind.com>
References: <20131217110512.GA11216@unicorn.suse.cz> <CAKfDRXi86Tb6ocJ9kegfQqWDcXG8i20yxdK0UqSnQ=1WWaaOuQ@mail.gmail.com> <20131217140101.GB11216@unicorn.suse.cz>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>
To: Michal Kubecek <mkubecek@suse.cz>,
	Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:45704 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753746Ab3LRJRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 04:17:00 -0500
Received: by mail-we0-f176.google.com with SMTP id w62so7073402wes.7
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 01:16:59 -0800 (PST)
In-Reply-To: <20131217140101.GB11216@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 17/12/2013 15:01, Michal Kubecek a =E9crit :
> On Tue, Dec 17, 2013 at 01:11:32PM +0100, Kristian Evensen wrote:
>> On Tue, Dec 17, 2013 at 12:05 PM, Michal Kubecek <mkubecek@suse.cz> =
wrote:
>>>
>>> Before I start with the patch, I would like to ask: would it be mor=
e
>>> appropriate to send the message when the route is marked as dead or=
 when
>>> it is actually deleted from the trie?
>>
>> I noticed the same thing a few months ago and submitted a patch
>> (http://www.spinics.net/lists/netdev/msg254106.html). However, it wa=
s
>> not applied because it would cause too much traffic on large-scale
>> routers (see davem's reply here
>> http://www.spinics.net/lists/netdev/msg254186.html).
>
> Thank you for the pointer. However, I agree that the inconsistencies
> (IPv4 vs. IPv6, RTM_DELROUTE vs. RTM_NEWROUTE) are really unfortunate=
=2E
Sure. Note that this fix is regularly proposed, another pointer:
http://patchwork.ozlabs.org/patch/195516/
