From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH v2 iproute2-next 1/4] include: update headers
Date: Fri, 06 Feb 2015 10:02:00 +0100
Message-ID: <54D48308.60509@6wind.com>
References: <54C8E3EB.8050904@6wind.com>	<1422454550-32222-1-git-send-email-nicolas.dichtel@6wind.com> <20150205102659.7b4a3ebb@urahara>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:58628 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753446AbbBFJCC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 04:02:02 -0500
Received: by mail-wi0-f175.google.com with SMTP id fb4so786358wid.2
        for <netdev@vger.kernel.org>; Fri, 06 Feb 2015 01:02:01 -0800 (PST)
In-Reply-To: <20150205102659.7b4a3ebb@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/02/2015 19:26, Stephen Hemminger a =E9crit :
> On Wed, 28 Jan 2015 15:15:47 +0100
> Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
>
>> Copy from sanitized headers.
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> ---
>>
>> v2: took last headers from net-next
>>
>>   include/linux/if_link.h       |  4 ++++
>>   include/linux/neighbour.h     |  1 +
>>   include/linux/net_namespace.h | 23 +++++++++++++++++++++++
>>   include/linux/rtnetlink.h     |  5 +++++
>>   4 files changed, 33 insertions(+)
>>   create mode 100644 include/linux/net_namespace.h
>
> All kernel headers for iproute2 must come from the result of:
>    $ make headers_install
I've done this.

>
> Please submit a patch to net-next which makes net_namespace.h
> (from include/uapi/linux/net_namespace.h) get correctly installed int=
o
> usr/include/linux/net_namespace.h
>
> The file is missing from include/uapi/linux/Kbuild
Hmm, I'm probably missing something (with net-next):
$ git grep net_namespace.h include/uapi/linux/Kbuild
include/uapi/linux/Kbuild:header-y +=3D net_namespace.h
$ rm -rf usr/include/
$ make headers_install
$ find usr/include/ -name net_namespace.h
usr/include/linux/net_namespace.h
