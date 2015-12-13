From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] ravb: ptp: fix misplaced ravb_ptp_stop() calling
 in ravb_probe()
Date: Mon, 14 Dec 2015 00:10:31 +0300
Message-ID: <566DDEC7.9050302@cogentembedded.com>
References: <1449599969-20628-1-git-send-email-ykaneko0929@gmail.com>
 <566838CB.10500@cogentembedded.com>
 <CAH1o70KogcskpKP+yx3A52c3spAakroRiAuRfi4HkkQq0NguHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:33567 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752416AbbLMVKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2015 16:10:35 -0500
Received: by lbbkw15 with SMTP id kw15so95828619lbb.0
        for <netdev@vger.kernel.org>; Sun, 13 Dec 2015 13:10:33 -0800 (PST)
In-Reply-To: <CAH1o70KogcskpKP+yx3A52c3spAakroRiAuRfi4HkkQq0NguHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/13/2015 06:39 PM, Yoshihiro Kaneko wrote:

>>> 'commit <f5d7837f96e5> ("ravb: ptp: Add CONFIG mode support")' added
>>> a calling of ravb_ptp_stop() in a wrong place in ravb_probe().
>>>
>>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
>>
>>
>>     Well, this patch is good to apply anyway:
>
> I thought that the interrupt should be disabled before freeing memory.
> anyway, thanks.

    You mean PTP interrupts?

MBR, Sergei
