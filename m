From: Jesse Gross <jesse@nicira.com>
Subject: Re: [RFC][net-next-2.6 PATCH 4/4] net: remove check for headroom in vlan_dev_create
Date: Tue, 26 Oct 2010 19:07:54 -0700
Message-ID: <AANLkTimYGADLrfYrY6kth7EDeiGXsvSY8wS=3dxVQ3cC@mail.gmail.com>
References: <20101021221004.22906.58438.stgit@jf-dev1-dcblab>
	<20101021221020.22906.96059.stgit@jf-dev1-dcblab>
	<AANLkTinREMV1bRhoJuiRV805-e1NKdZD6ejyhYczpw_E@mail.gmail.com>
	<4CC750B8.7060607@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56014 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758797Ab0J0CH4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 22:07:56 -0400
Received: by wyf28 with SMTP id 28so152192wyf.19
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 19:07:55 -0700 (PDT)
In-Reply-To: <4CC750B8.7060607@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 26, 2010 at 3:05 PM, John Fastabend
<john.r.fastabend@intel.com> wrote:
> On 10/25/2010 3:45 PM, Jesse Gross wrote:
>> On Thu, Oct 21, 2010 at 3:10 PM, John Fastabend
>> <john.r.fastabend@intel.com> wrote:
>>> It is possible for the headroom to be smaller then the
>>> hard_header_len for a short period of time after toggling
>>> the vlan offload setting.
>>>
>>> This is not a hard error and skb_cow_head is called in
>>> __vlan_put_tag() to resolve this.
>>>
>>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>>
>> How is it possible that the hard_header_len changes on the vlan
>> device? =A0It looks like the header length never gets changed after =
it
>> is initialized. =A0There's no set_flags method in the vlan device to
>> toggle whether it is using offloading or not, it just rides on top o=
f
>> the underlying device.
>
> Your right and I think this is why my previous patch was broken. If w=
e
> can toggle the underlying offloads we should set the header length as
> well. With the updated patch I just sent this should be true now.

OK, it makes sense it that context.
Acked-by: Jesse Gross <jesse@nicira.com>

Thanks.
