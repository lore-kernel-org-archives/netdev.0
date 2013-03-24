From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next] ip_gre: increase inner ip header ID only for IPv4
Date: Sat, 23 Mar 2013 21:13:09 -0700
Message-ID: <CALnjE+qTr5LxozvmN2yBZMN88ra6SVchHcmbgMXhh0cG1ZM41w@mail.gmail.com>
References: <1364016584-7189-1-git-send-email-amwang@redhat.com>
	<CALnjE+qJ-BaGYEohfWB3-ZWaa9LwhFi5maR=yjP5_TD5N_jtog@mail.gmail.com>
	<1364092641.10694.2.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog105.obsmtp.com ([74.125.149.75]:51302 "HELO
	na3sys009aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750742Ab3CXENK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 00:13:10 -0400
Received: by mail-ia0-f198.google.com with SMTP id y26so17044710iab.9
        for <netdev@vger.kernel.org>; Sat, 23 Mar 2013 21:13:09 -0700 (PDT)
In-Reply-To: <1364092641.10694.2.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 23, 2013 at 7:37 PM, Cong Wang <amwang@redhat.com> wrote:
> On Sat, 2013-03-23 at 16:36 -0700, Pravin Shelar wrote:
>> On Fri, Mar 22, 2013 at 10:29 PM, Cong Wang <amwang@redhat.com> wrote:
>> > From: Cong Wang <amwang@redhat.com>
>> >
>> > Pravin pointed out the inner network header of a GRE tunnel packet
>> > could be IPv6, where there is no ID. So we should check the version.
>> >
>>
>> inet_gso_segment() already increment ip-header identification. What is
>> problem with that?
>
> Let tcpdump speak:
>
> (Inner ID is always 3b65 without my patch)
>
Thanks for report.
I just sent out fix, Can you please try that.
