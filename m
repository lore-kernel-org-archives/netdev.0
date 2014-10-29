From: Erik Kline <ek@google.com>
Subject: Re: [PATCH v2 net-next] net: ipv6: Add a sysctl to make optimistic
 addresses useful candidates
Date: Wed, 29 Oct 2014 18:36:51 +0900
Message-ID: <CAAedzxoBoyO3pnVJa2KUYDm9j2a7hYHnPowpAiet+R7K016EKw@mail.gmail.com>
References: <1414487474-18201-1-git-send-email-ek@google.com>
 <CAKD1Yr2PSJ0=YV4m5jPyvt6cvNv8+-joft6L2DxO_5YLH6C7AQ@mail.gmail.com> <CAAedzxptbKLrO_0uPVqXiqOACqNNj9BeeakgB3+t+XxemeN3Sw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	Lorenzo Colitti <lorenzo@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f50.google.com ([209.85.216.50]:56483 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755726AbaJ2JhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 05:37:12 -0400
Received: by mail-qa0-f50.google.com with SMTP id bm13so50834qab.23
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2014 02:37:12 -0700 (PDT)
In-Reply-To: <CAAedzxptbKLrO_0uPVqXiqOACqNNj9BeeakgB3+t+XxemeN3Sw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(resending; sorry for the dup; my text mail setting was defeated)-:

On Wed, Oct 29, 2014 at 6:34 PM, Erik Kline <ek@google.com> wrote:
> Hannes,
>
> Given that we spoke about this reduction in the number of netlink messages
> earlier, do you still think it's an issue?
>
> The end result here is that for listeners on netlink sockets on systems that
> (a) have optimistic dad built-in, (b) have optimistic dad enabled, and (c)
> have use_optimistic set: they'll 2 notifications (with different flags) for
> automatically added addresses on these interfaces.
>
> (Personally, given that we appear to send an RTM_NEWADDR when the address
> gets deprecated (I think), I think sending one on every flag change of
> interest is in keeping with existing behaviour.)
>
> On Wed Oct 29 2014 at 12:15:59 AM Lorenzo Colitti <lorenzo@google.com>
> wrote:
>>
>> On Tue, Oct 28, 2014 at 6:11 PM, Erik Kline <ek@google.com> wrote:
>> > Add a sysctl that causes an interface's optimistic addresses
>> > to be considered equivalent to other non-deprecated addresses
>> > for source address selection purposes.  Preferred addresses
>> > will still take precedence over optimistic addresses, subject
>> > to other ranking in the source address selection algorithm.
>> > ...
>> > Signed-off-by: Erik Kline <ek@google.com>
>>
>> Acked-by: Lorenzo Colitti <lorenzo@google.com>
