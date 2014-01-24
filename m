From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next v2 1/5] net_sched: act: hide struct tcf_common
 from API
Date: Thu, 23 Jan 2014 16:45:32 -0800
Message-ID: <CAM_iQpXEHf+yvL1D7+FSCYZ9xVoekNGmR1O8LZDhK0ZZ3ma3aQ@mail.gmail.com>
References: <1390516525-8556-1-git-send-email-xiyou.wangcong@gmail.com>
	<1390516525-8556-2-git-send-email-xiyou.wangcong@gmail.com>
	<20140123160413.37804c6c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:35141 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755688AbaAXApe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 19:45:34 -0500
Received: by mail-oa0-f46.google.com with SMTP id n16so3032400oag.19
        for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 16:45:33 -0800 (PST)
In-Reply-To: <20140123160413.37804c6c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 23, 2014 at 4:04 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Thu, 23 Jan 2014 14:35:21 -0800
> Cong Wang <xiyou.wangcong@gmail.com> wrote:
>
>> +#define to_defact(a) \
>> +     container_of(a->priv, struct tcf_defact, common)
>
> also macro args should be in parens.
>

The problems you mentioned are not introduced by
my patch. They have been there for a long time.
