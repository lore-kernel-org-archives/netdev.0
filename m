From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [iproute2 1/1] man: tc-ife.8: man page for ife action
Date: Mon, 2 May 2016 19:40:58 -0400
Message-ID: <5727E58A.3080307@mojatatu.com>
References: <1462013884-4971-1-git-send-email-jhs@emojatatu.com>
 <20160502151032.5701009e@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, phil@nwl.cc, lucasb@mojatatu.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:37576 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932362AbcEBXlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 19:41:11 -0400
Received: by mail-ig0-f173.google.com with SMTP id s8so6517303ign.0
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 16:41:10 -0700 (PDT)
In-Reply-To: <20160502151032.5701009e@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-05-02 06:10 PM, Stephen Hemminger wrote:
> On Sat, 30 Apr 2016 06:58:04 -0400
> Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>
>> From: Lucas Bates <lucasb@mojatatu.com>
>>
>> Signed-off-by: Lucas Bates <lucasb@mojatatu.com>
>> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>
> Still waiting for a you to respond to my earlier suggestions about tc-ife.
>

I did respond.

> Last version I saw was expecting header in include/linux which is not in
> kernel source.
>
> ~/kernel/net-next$ ls include/uapi/linux/tc_ife.h
> ls: cannot access include/uapi/linux/tc_ife.h: No such file or directory
>

What version of net-next are you looking at? This is what i see:

linux-gits/net-next$ ls  include/uapi/linux/tc_act/
Kbuild         tc_csum.h      tc_ife.h       tc_nat.h       tc_vlan.h
tc_bpf.h       tc_defact.h    tc_ipt.h       tc_pedit.h
tc_connmark.h  tc_gact.h      tc_mirred.h    tc_skbedit.h


> You need to get that header in right place, and get it exported correctly.

And I saw you sending a patch which tried to export everything. What
did i miss? ;-> If that didnt make i will send one just for IFE.


cheers,
jamal

PS:- I have other patches which fix a small issue with some actions
(which include ife) - but they are depending on this other one going
in.
