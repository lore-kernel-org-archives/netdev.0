From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH iproute2] vxlan: allow specifying multiple default destinations
Date: Sun, 2 Jun 2013 10:09:23 +0300
Message-ID: <CAF1J0HP4Oi04PK-JFwy1h7_n=MxiA-c5DTjPSTHjwGrxs+jUZg@mail.gmail.com>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>
	<1369821617-29098-4-git-send-email-mike.rapoport@ravellosystems.com>
	<ko4kcr$h8j$1@ger.gmane.org>
	<CAF1J0HPDAkhAybQt-tOFLLTLzaXiWy_TSbFF2FT3PMaXbnxJuw@mail.gmail.com>
	<20130529155625.2ee5f6bb@nehalam.linuxnetplumber.net>
	<CAF1J0HNiBED=BLHqPPk8w2=DDvSWdZwMPvtag6rpPhxnboT4GA@mail.gmail.com>
	<20130530114424.GC10532@casper.infradead.org>
	<20130530124652.GA29547@zed.ravello.local>
	<20130530155719.GD10532@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog101.obsmtp.com ([74.125.245.70]:37483 "HELO
	na3sys010aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750711Ab3FBHJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jun 2013 03:09:24 -0400
Received: by mail-ob0-f177.google.com with SMTP id ta17so5392831obb.8
        for <netdev@vger.kernel.org>; Sun, 02 Jun 2013 00:09:23 -0700 (PDT)
In-Reply-To: <20130530155719.GD10532@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 30, 2013 at 6:57 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 05/30/13 at 03:46pm, Mike Rapoport wrote:
>> I'm feeling Ok about "ip link set [..] dstadd/dstdel". What does bother
>> me is that you can't have different parameters for "ip link add" and "ip
>> link set" for vxlan (and other iplink) utility. So, one can use
>> ip link add [..] dstdel
>> which does not make sense...
>
> You can easily pass an additional argument into iplink_modify()
> and exclude certain options in the "add" use case.

I think there's no need to pass an additional argument to iplink_modify.
The vxlan_parse_opts may check the flags in nlmsghdr to distinguish
between the "add" and "set" cases.
Than we'll have 'ip link add [..]' as it was and the 'ip link set
[..]' will be used to manage default destinations.

--
Sincerely yours,
Mike.
