From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCH net-next] openvswitch: Fix serialization of non-masked set actions.
Date: Tue, 3 Mar 2015 12:38:54 -0800
Message-ID: <CANr6G5zPg_RC=Dw=KD=AW4O4DY2j=Sc81SSYnfp8ZvyrkYOgLw@mail.gmail.com>
References: <1425350996-2930-1-git-send-email-joestringer@nicira.com> <20150303.143945.661201418308735762.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Jarno Rajahalme <jrajahalme@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog102.obsmtp.com ([74.125.149.69]:52853 "HELO
	na3sys009aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756650AbbCCUjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 15:39:16 -0500
Received: by mail-we0-f171.google.com with SMTP id w55so42250697wes.4
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 12:39:14 -0800 (PST)
In-Reply-To: <20150303.143945.661201418308735762.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3 March 2015 at 11:39, David Miller <davem@davemloft.net> wrote:
> From: Joe Stringer <joestringer@nicira.com>
> Date: Mon,  2 Mar 2015 18:49:56 -0800
>
>> Set actions consist of a regular OVS_KEY_ATTR_* attribute nested inside
>> of a OVS_ACTION_ATTR_SET action attribute. When converting masked actions
>> back to regular set actions, the inner attribute length was not changed,
>> ie, double the length being serialized. This patch fixes the bug.
>>
>> Fixes: 83d2b9b ("net: openvswitch: Support masked set actions.")
>> Signed-off-by: Joe Stringer <joestringer@nicira.com>
>> ---
>> This fix needs to be applied to net as well; it applies cleanly.
>
> This is backwards, don't do this.  Just say that 'net' needs the fix
> and submit it targetting that tree only.  Things in 'net' propagate
> into 'net-next' automatically as I do merges over time, but the
> opposite is not true.

OK, I'll resend.
