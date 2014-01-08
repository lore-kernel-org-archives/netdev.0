From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: Possible to add netfilter hooks to IFB driver?
Date: Wed, 08 Jan 2014 07:28:44 -0500
Message-ID: <52CD447C.4080708@mojatatu.com>
References: <522653F1.6090902@ecessa.com>	<20140106135123.3c7e6645@nehalam.linuxnetplumber.net>	<CAKTPYJTDj82YM8peU-bbS5OtuXnq1ty4+f-Wyk_bE2LBf4vGmw@mail.gmail.com> <20140107111807.38624f74@rainbow.cbg.collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Brad Johnson <bjohnson@ecessa.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alban Crequy <alban.crequy@collabora.co.uk>,
	Andrew Collins <bsderandrew@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:51095 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755773AbaAHM2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 07:28:46 -0500
Received: by mail-ig0-f172.google.com with SMTP id hl1so12967248igb.5
        for <netdev@vger.kernel.org>; Wed, 08 Jan 2014 04:28:46 -0800 (PST)
In-Reply-To: <20140107111807.38624f74@rainbow.cbg.collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/14 06:18, Alban Crequy wrote:
> On Mon, 6 Jan 2014 15:51:37 -0700
> Andrew Collins <bsderandrew@gmail.com> wrote:
>
>> On Mon, Jan 6, 2014 at 2:51 PM, Stephen Hemminger
>> <stephen@networkplumber.org> wrote:
>>>
>>> The risk is creating the same races that made IMQ unacceptable.
>>> --
>>
>> I believe openwrt nowadays uses a TC action which runs the packet
>> through prerouting then pulls in the mark off the ct entry into the
>> skb, so ingress+IFB can take action on it.
>
> Thanks for the info. I guess the implementation is this one:
>
> https://dev.openwrt.org/browser/trunk/target/linux/generic/patches-3.12/621-sched_act_connmark.patch
> https://dev.openwrt.org/browser/trunk/package/network/utils/iproute2/patches/210-add-act_connmark.patch
> https://dev.openwrt.org/browser/trunk/package/network/config/qos-scripts/files/usr/lib/qos/generate.sh#L343
>
>> Perhaps a cleaned up version of this would be suitable for upstream?
>
> I don't know but this seems a useful feature to me.
>

I like that approach - discussion was had here on netdev
about a year ago refer to:
http://marc.info/?t=135591832200007&r=1&w=2
since it is a long thread, jump to here:
http://marc.info/?l=linux-netdev&m=135634890120552&w=2

I believe Pablo brought it up at the last netfilter meeting
and there was no disagreement to get it going.
I dont know if kids still use these expressions - but send him
some virtual beer and he may return the love.


cheers,
jamal
