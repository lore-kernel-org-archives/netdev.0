From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 3/3] bridge: new function to pack vlans into
 ranges during gets
Date: Mon, 12 Jan 2015 15:52:30 -0800
Message-ID: <54B45E3E.4030508@cumulusnetworks.com>
References: <1420903874-25528-4-git-send-email-roopa@cumulusnetworks.com> <20150112234751.GA16617@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, vyasevic@redhat.com,
	wkok@cumulusnetworks.com, sfeldma@gmail.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:50827 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489AbbALXwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 18:52:34 -0500
Received: by mail-qg0-f46.google.com with SMTP id q107so20047892qgd.5
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 15:52:33 -0800 (PST)
In-Reply-To: <20150112234751.GA16617@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/12/15, 3:47 PM, Thomas Graf wrote:
> On 01/10/15 at 07:31am, roopa@cumulusnetworks.com wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This patch adds new function to pack vlans into ranges
>> whereever applicable using the flags BRIDGE_VLAN_INFO_RANGE_BEGIN
>> and BRIDGE VLAN_INFO_RANGE_END
>>
>> Old vlan packing code is moved to a new function and continues to be
>> called when filter_mask is RTEXT_FILTER_BRVLAN.
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Roopa,
>
> Just came across these new warnings:
>
> net/bridge/br_netlink.c: In function =E2=80=98br_fill_ifinfo=E2=80=99=
:
> net/bridge/br_netlink.c:146:32: warning: =E2=80=98vid_range_flags=E2=80=
=99 may be used uninitialized in this function [-Wmaybe-uninitialized]
>    err =3D br_fill_ifvlaninfo_range(skb, vid_range_start,
>                                  ^
> net/bridge/br_netlink.c:108:6: note: =E2=80=98vid_range_flags=E2=80=99=
 was declared here
>    u16 vid_range_flags;
sorry abt that, patch coming...in a few mins. compiling...
Don't remember seeing it during my compilation...

Thanks!
