From: lucien xin <lucien.xin@gmail.com>
Subject: Re: [PATCH] ipv6: ip6_append_data_mtu do not handle the mtu of the
 second fragment properly
Date: Sun, 16 Mar 2014 12:50:31 +0800
Message-ID: <CADvbK_dzTX64DwHmebT=FB8nAg6teKaWw58nUYXoshJcVuhaYQ@mail.gmail.com>
References: <1394512309-8823-1-git-send-email-lucien.xin@gmail.com>
	<20140311144906.GA29404@order.stressinduktion.org>
	<CADvbK_fS0rhPodczcZ52YN9D7NBY_TG+6xXvt-shvvz+e3qLnw@mail.gmail.com>
	<20140312102646.GD29404@order.stressinduktion.org>
	<CADvbK_eZ5AO3g7uHRykspHouXnvtCTf0dUWOXf8hd3r0wV6Hnw@mail.gmail.com>
	<20140315155519.GA12291@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: lucien xin <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>,
	Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f182.google.com ([74.125.82.182]:51963 "EHLO
	mail-we0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750732AbaCPEud convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Mar 2014 00:50:33 -0400
Received: by mail-we0-f182.google.com with SMTP id p61so3503387wes.27
        for <netdev@vger.kernel.org>; Sat, 15 Mar 2014 21:50:32 -0700 (PDT)
In-Reply-To: <20140315155519.GA12291@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 15, 2014 at 11:55 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Thu, Mar 13, 2014 at 01:38:15PM +0800, lucien xin wrote:
>> On Wed, Mar 12, 2014 at 6:26 PM, Hannes Frederic Sowa
>> <hannes@stressinduktion.org> wrote:
>> > On Wed, Mar 12, 2014 at 10:40:50AM +0800, lucien xin wrote:
>> >
>> > It would be possible if we are absolutely sure if we don't call
>> > ip6_append_data_mtu a second time, which I have not yet reviewed.
>> >
>> > The line I proposed above may also suffer from this problem.
>> >
>> > Maybe you already checked that?
>> >
>> hmm... this problem do exist.  when it enter "the while( length>0 ){
>> }" with skb !=3D NULL first, the problem
>> will happen, of course, perhaps there are also other cases that
>> trigger that problem.  because  that code seems
>> a little mess=EF=BC=8C I hope the following change can make it more =
clear and
>> eliminate potential insecurity,
>> pls help to check it
>
> The diff is good, thanks!
>
okay , I'll repost it.
