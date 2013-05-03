From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next] gre: Fix GREv4 TCPv6 segmentation.
Date: Fri, 3 May 2013 15:54:11 -0700
Message-ID: <CALnjE+qniQGq8azFE0AwmY545zgD+71fLtGmxzrytN_fVhMa1A@mail.gmail.com>
References: <1367547259-17919-1-git-send-email-pshelar@nicira.com>
	<20130503.161149.1251743328601859737.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, sesse@google.com, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog101.obsmtp.com ([74.125.149.67]:54037 "HELO
	na3sys009aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1761974Ab3ECWyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 18:54:13 -0400
Received: by mail-ob0-f199.google.com with SMTP id 16so10398467obc.6
        for <netdev@vger.kernel.org>; Fri, 03 May 2013 15:54:12 -0700 (PDT)
In-Reply-To: <20130503.161149.1251743328601859737.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 3, 2013 at 1:11 PM, David Miller <davem@davemloft.net> wrote:
> From: Pravin B Shelar <pshelar@nicira.com>
> Date: Thu,  2 May 2013 19:14:19 -0700
>
>> For ipv6 traffic, GRE can generate packet with strange GSO
>> bits, e.g. ipv4 packet with SKB_GSO_TCPV6 flag set.  Therefore
>> following patch relaxes check in inet gso handler to allow
>> such packet for segmentation.
>> This patch also fixes wrong skb->protocol set that was done in
>> gre_gso_segment() handler.
>>
>> Reported-by: Steinar H. Gunderson <sesse@google.com>
>> CC: Eric Dumazet <eric.dumazet@gmail.com>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>
> Applied.

Hi David,

This patch needs to be queued for -stable.

Thanks.
