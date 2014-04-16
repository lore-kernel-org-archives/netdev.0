From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch iproute2] u32: add terminal parameter
Date: Wed, 16 Apr 2014 08:19:22 -0400
Message-ID: <534E754A.8020403@mojatatu.com>
References: <1396631826-15188-1-git-send-email-xiyou.wangcong@gmail.com>	<20140411140446.6412e9dc@nehalam.linuxnetplumber.net>	<CAM_iQpVpNOJ1xiK45qXGRXgBZ2QcmwoPc7p=SOHCo=1kTwPfFQ@mail.gmail.com>	<20140411175800.08e9ffe3@nehalam.linuxnetplumber.net>	<CAM_iQpU7Ntn-yo-ez0vP2BhKe+-Vaq1w_+MQhFPHM-bbQZx2gg@mail.gmail.com>	<534926F7.10505@mojatatu.com>	<CAM_iQpXJnOOUbpS0WwrB7C50LGxcLhMEQPrDB84Zm-SLKVHh6w@mail.gmail.com>	<534C6BDE.8020600@mojatatu.com>	<CAM_iQpV8GeEQr+GFFy2Etct_51YhvXEBKydyH9q4NP5QbsDOnA@mail.gmail.com>	<534D2D62.5080109@mojatatu.com> <CAM_iQpVmxmutCXMucP65UoxtPON=vJrxQ3B_jDTpMjWPycebaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:33616 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751377AbaDPMTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 08:19:47 -0400
Received: by mail-ie0-f174.google.com with SMTP id rp18so10383258iec.19
        for <netdev@vger.kernel.org>; Wed, 16 Apr 2014 05:19:46 -0700 (PDT)
In-Reply-To: <CAM_iQpVmxmutCXMucP65UoxtPON=vJrxQ3B_jDTpMjWPycebaw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/15/14 16:17, Cong Wang wrote:

>
> I knew, I thought at least classid is an alternative for action, that is,
> one doing classify and one doing some other action.
>

Indeed you could look at setting the flowid as "default action".

>
> I see. The next question would be what is a reasonable classid
> value for a classless qdisc? Or can we set it to some value to express
> "we don't care"?
>

Mostly it is dont care (and no new syntax is introduced); however,
like i pointed out with the route classifier there could be correlation
with other things  downstream.

cheers,
jamal
