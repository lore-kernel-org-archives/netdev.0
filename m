From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] openvswitch: Reset key metadata for packet execution.
Date: Wed, 11 Feb 2015 14:57:14 -0800
Message-ID: <CALnjE+qY4SzqujSrXOtpW6PxLD+7uj7fSara3ND0w+6w3vVHug@mail.gmail.com>
References: <1423604116-1438-1-git-send-email-pshelar@nicira.com>
	<20150211.144056.991311291193384410.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog130.obsmtp.com ([74.125.149.143]:52887 "HELO
	na3sys009aog130.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752282AbbBKW5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 17:57:15 -0500
Received: by mail-ie0-f178.google.com with SMTP id rd18so7804649iec.5
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2015 14:57:14 -0800 (PST)
In-Reply-To: <20150211.144056.991311291193384410.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 11, 2015 at 2:40 PM, David Miller <davem@davemloft.net> wrote:
> From: Pravin B Shelar <pshelar@nicira.com>
> Date: Tue, 10 Feb 2015 13:35:16 -0800
>
>> Userspace packet execute command pass down flow key for given
>> packet. But userspace can skip some parameter with zero value.
>> Therefore kernel needs to initialize key metadata to zero.
>>
>> Fixes: 0714812134 ("openvswitch: Eliminate memset() from flow_extract.")
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>
> Applied, but...
>
>> +     memset(key, 0, OVS_SW_FLOW_KEY_METADATA_SIZE);
>
> There's a space before the TAB in that indentation, and git even
> warns about this when applying patches.
>
> I fixed it up, but this is one of the basic things you should be
> dealing with before submitting your changes.
>

Thanks for fixing the patch.
