From: Vinson Lee <vlee@twopensource.com>
Subject: Re: Please backport dev_kfree_skb_any fixes for stable
Date: Wed, 25 Mar 2015 10:48:47 -0700
Message-ID: <CAHTgTXWvDs4fTg_Gpsn8XrYnHbgZOKC4ymkq_QVdnGVCOaiqzw@mail.gmail.com>
References: <20140627.163813.1794281555636065922.davem@davemloft.net>
	<CAHA+R7N52T1NNzytbiJ0Qoc=L3tiZRJRU+8bCET-ieeih_XS8Q@mail.gmail.com>
	<CAHTgTXX2rw9441stUb41EHTKanm9HZ+4T+a5+fur4O6G7zy21A@mail.gmail.com>
	<20150324.001408.1364899234285488351.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Netdev <netdev@vger.kernel.org>,
	Cong Wang <cwang@twopensource.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:35901 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752619AbbCYRss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 13:48:48 -0400
Received: by oicf142 with SMTP id f142so18978511oic.3
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 10:48:48 -0700 (PDT)
In-Reply-To: <20150324.001408.1364899234285488351.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 23, 2015 at 9:14 PM, David Miller <davem@davemloft.net> wrote:
> From: Vinson Lee <vlee@twopensource.com>
> Date: Tue, 17 Mar 2015 16:52:20 -0700
>
>> This stable request seems to have been forgotten.
>
> Sorry I've lost all of the context for this, you'll have to remind me
> of all of the details.

These patches fixes warnings that can occur when a netconsole message
is transmitted in an IRQ.
