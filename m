From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: A performance regression of gretap
Date: Wed, 10 Jul 2013 19:28:06 -0700
Message-ID: <CALnjE+oNMcXORdMgzHtomdf+EDknZaCsiB-+aevMbg-rsxbpww@mail.gmail.com>
References: <327738182.1491147.1373450503005.JavaMail.root@redhat.com>
	<1373508910.12250.4.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog124.obsmtp.com ([74.125.149.151]:43983 "HELO
	na3sys009aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755063Ab3GKC2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 22:28:08 -0400
Received: by mail-qa0-f42.google.com with SMTP id hu16so7444903qab.1
        for <netdev@vger.kernel.org>; Wed, 10 Jul 2013 19:28:06 -0700 (PDT)
In-Reply-To: <1373508910.12250.4.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 10, 2013 at 7:15 PM, Cong Wang <amwang@redhat.com> wrote:
> On Wed, 2013-07-10 at 06:01 -0400, Cong Wang wrote:
>>
>> Could you please take a look? And, gre tunnel is fine, this
>> problem only exists for gretap. I reviewed the gretap code,
>> but can't find any bug.
>
> After digging it a little bit, I found some of the packets on RX side
> have incorrect TCP checksum after going through gretap, while the
> packets captured on eth0 are all correct.
>
> Thanks.
>
I do not see it on my end.
Can you tell me NIC type and features set for eth device?
