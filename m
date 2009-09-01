From: Lisong Xu <lisongxu2@gmail.com>
Subject: Re: TCP Congestion Control Algorithms
Date: Mon, 31 Aug 2009 19:37:34 -0500
Message-ID: <a45e9b40908311737kdafa7d2m80ebea5326e81933@mail.gmail.com>
References: <a45e9b40908311408l15d68088i459d6a1000cbca07@mail.gmail.com>
	 <a45e9b40908311410m486a60fel6a81c334732de358@mail.gmail.com>
	 <20090831150731.28c36081@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f175.google.com ([209.85.222.175]:56141 "EHLO
	mail-pz0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751981AbZIAAhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 20:37:31 -0400
Received: by pzk5 with SMTP id 5so3216643pzk.21
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2009 17:37:34 -0700 (PDT)
In-Reply-To: <20090831150731.28c36081@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks, Stephen!
Lisong

On Mon, Aug 31, 2009 at 5:07 PM, Stephen Hemminger<shemminger@vyatta.com> wrote:
> On Mon, 31 Aug 2009 16:10:59 -0500
> Lisong Xu <lisongxu2@gmail.com> wrote:
>
>> Hello,
>>
>> Since there are multiple different TCP congestion control algorithms
>> available in Linux, a Linux server may use any of them.
>>
>> Is it possible for a regular user to find out the exact TCP congestion
>> control algorithm used by a Linux server? For example, if I am
>> downloading a file from a remote Linux server using a TCP flow, can I
>> find out whether this flow is a TCP/CUBIC flow, or TCP/Newreno, or
>> some other TCP protocol?
>>
>
> No. you might be able to some nmap style guessing, but no remote
> API. You can see locally on the server through /proc/sys/net
>
