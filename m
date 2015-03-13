From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 0/3] switchdev: support stp updates on stacked
 netdevices
Date: Fri, 13 Mar 2015 06:25:24 -0700
Message-ID: <5502E544.7030003@cumulusnetworks.com>
References: <1426206598-29410-1-git-send-email-roopa@cumulusnetworks.com> <20150313.001007.65274068513753002.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:41951 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755441AbbCMNZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 09:25:25 -0400
Received: by pablj1 with SMTP id lj1so29500184pab.8
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 06:25:24 -0700 (PDT)
In-Reply-To: <20150313.001007.65274068513753002.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/12/15, 9:10 PM, David Miller wrote:
> From: roopa@cumulusnetworks.com
> Date: Thu, 12 Mar 2015 17:29:55 -0700
>
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This series moves bridge stp update api to follow the setlink/dellink
>> apis to propagate stp state updates to switch ports on stacked netdevs
>>
>> v1 -> v2:
>> 	fix comment
>> 	add CONFIG_NET_SWITCHDEV checks
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Can't we just do this stacked device traveral transparently?
>
> That seems much cleaner to me.
David, if you mean not touch bond and team but have the switchdev api do 
it transparently, yes, i had it that way initially.
And i do liked it that way as well. But the feedback i received (during 
the initial introduction of this for setlink/dellink) was to make it 
explicit for each master.

Thanks,
Roopa
