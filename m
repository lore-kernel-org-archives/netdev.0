From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next 0/2] handle_ing update
Date: Mon, 11 May 2015 15:42:04 -0700
Message-ID: <CAHA+R7Ou5pv7FoX5BgUQeCKfw4AHD-O+pdqgwk9cOscccxQUGQ@mail.gmail.com>
References: <cover.1431203900.git.daniel@iogearbox.net>
	<20150510170550.GA4442@salvia>
	<20150511.110949.1369224056076525434.davem@davemloft.net>
	<CAHA+R7Od3WWS+sM0cr7=4YEB4qMiY61dfrfH_+Eeayi=LxzEsw@mail.gmail.com>
	<55512BFD.3070400@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:34913 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423AbbEKWmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 18:42:06 -0400
Received: by wgbhc8 with SMTP id hc8so44138101wgb.2
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 15:42:05 -0700 (PDT)
In-Reply-To: <55512BFD.3070400@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 11, 2015 at 3:23 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On 5/11/15 3:03 PM, Cong Wang wrote:
>>
>> On Mon, May 11, 2015 at 8:09 AM, David Miller <davem@davemloft.net> wrote:
>>>
>>> There is no difference between having ingress qdisc hanging off of
>>> netdevice vs. the classifier list.  They both serve the same purpose
>>> and the change to use the classifier list merely removes one level
>>> of indirection.
>>
>>
>> With adding 8 bytes to each of the netdevice even when it doesn't
>> have ingress qdisc attached at all...
>
>
> we already said several times that the work is already on the way
> to remove 'ingress_queue' from net_device. It will save much more
> memory than addition of 8 bytes.

This sounds like adding 8 bytes is a must step for removing more,
I seriously doubt.
