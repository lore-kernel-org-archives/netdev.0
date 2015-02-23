From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: add vlan info to bridge setlink and
 dellink notification messages
Date: Sun, 22 Feb 2015 20:43:00 -0800
Message-ID: <54EAAFD4.3060400@cumulusnetworks.com>
References: <1424578911-6813-1-git-send-email-roopa@cumulusnetworks.com> <20150222.230200.417142094091853578.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	vyasevic@redhat.com, sfeldma@gmail.com, wkok@cumulusnetworks.com,
	siva.mannem.lnx@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:42601 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651AbbBWEnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2015 23:43:03 -0500
Received: by pdbfp1 with SMTP id fp1so22562852pdb.9
        for <netdev@vger.kernel.org>; Sun, 22 Feb 2015 20:43:01 -0800 (PST)
In-Reply-To: <20150222.230200.417142094091853578.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/22/15, 8:02 PM, David Miller wrote:
> From: roopa@cumulusnetworks.com
> Date: Sat, 21 Feb 2015 20:21:51 -0800
>
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> vlan add/deletes are not notified to userspace today. This patch adds
>> vlan info to bridge newlink/dellink notifications generated from the bridge
>> driver. Notifications use the RTEXT_FILTER_BRVLAN_COMPRESSED flag to compress vlans into ranges whereever applicable.
> Please format your commit message text to ~80 columns in the
> future, thanks.

sorry abt that. ack, thanks.
>
>> The size calculations does not take ranges into account for simplicity.
>> This has the potential for allocating a larger skb than required.
>>
>> There is an existing inconsistency with bridge NEWLINK and
>> DELLINK change notifications. Both generate NEWLINK notifications.
>> Since its always a NEWLINK notification, this patch includes all
>> vlans the port belongs to in the notification. The NEWLINK and DELLINK
>> request messages however only include the vlans to be added and
>> deleted.
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> This looks fine to me, applied.
>
> If you would put at least some time into trying to reduce the
> allocation size, taking range compression into consideration,
> I'd very much appreciate it as a follow-on patch.
will do, thanks.
