From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net] macvlan: add NETIF_F_NETNS_LOCAL flag
Date: Mon, 10 Feb 2014 18:25:51 -0800
Message-ID: <CAHA+R7N2rxt5vyF+i8mi04dJaLk5bCgMAZOCexOLULLcQ-mT6w@mail.gmail.com>
References: <1392082593-7742-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140211014535.GA11150@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:45900 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751779AbaBKCZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 21:25:53 -0500
Received: by mail-la0-f43.google.com with SMTP id pv20so5391507lab.16
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 18:25:51 -0800 (PST)
In-Reply-To: <20140211014535.GA11150@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 10, 2014 at 5:45 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Mon, Feb 10, 2014 at 05:36:33PM -0800, Cong Wang wrote:
>> From: Cong Wang <cwang@twopensource.com>
>>
>> BZ: https://bugzilla.kernel.org/show_bug.cgi?id=66691
>>
>> There is no point to allow moving a macvlan device to
>> another namespace while the lower device is still in
>> this namespace. tunnels already set this flag.
>
> Can't we solve this somehow differently, like not showing anything at all
> etc.? I guess this is a feature some people use and haven't noticed yet.
>

I don't understand what you mean by "not showing anything at all".
I assume you mean mac1@xxx, not matter whether we show xxx
here, mac1 relies on xxx to function.

Please give a real use case rather than just guessing, I don't think
there is any valid case until we support moving multiple devices into
a netns atomically.
