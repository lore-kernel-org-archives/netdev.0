From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net v3] rtnl/bond: don't send rtnl msg for unregistered
 iface
Date: Wed, 13 May 2015 14:01:05 +0200
Message-ID: <55533D01.6070207@6wind.com>
References: <555216DA.3020105@6wind.com> <1431443865-4327-1-git-send-email-nicolas.dichtel@6wind.com> <20150512155842.GA2081@nanopsycho> <20150512171248.GD9559@gospo.home.greyhouse.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, j.vosburgh@gmail.com,
	vfalico@gmail.com
To: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:34061 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933870AbbEMMBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 08:01:08 -0400
Received: by wicmc15 with SMTP id mc15so76933724wic.1
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 05:01:07 -0700 (PDT)
In-Reply-To: <20150512171248.GD9559@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/05/2015 19:12, Andy Gospodarek a =E9crit :
> On Tue, May 12, 2015 at 05:58:42PM +0200, Jiri Pirko wrote:
>> Tue, May 12, 2015 at 05:17:45PM CEST, nicolas.dichtel@6wind.com wrot=
e:
[snip]
>>> First, nobody seems to care about NETDEV_CHANGEINFODATA (commit
>>> d4261e565000 says that it was put only to notify userspace). Hence,=
 we can
>>> call directly rtmsg_ifinfo().
>>
>> Please leave this notifier here. Will be needed in very near future =
for
>> LAG offloading purposes.
>
> I agree with this.  It is extremely useful for a variety of reasons (=
not
> just the offload case), so please to do not remove it.
No problem, I will keep it.

=46or my knowledge, can you explain these "variety of reasons"?
