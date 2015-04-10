From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH iproute2-next 2/2] netns: allow to dump and monitor nsid
Date: Fri, 10 Apr 2015 16:03:29 +0200
Message-ID: <5527D831.7080703@6wind.com>
References: <1428568214-8673-1-git-send-email-nicolas.dichtel@6wind.com> <1428568214-8673-2-git-send-email-nicolas.dichtel@6wind.com> <20150409084805.GA2492@angus-think.wlc.globallogic.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:34407 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933075AbbDJODc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 10:03:32 -0400
Received: by widjs5 with SMTP id js5so16870219wid.1
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 07:03:31 -0700 (PDT)
In-Reply-To: <20150409084805.GA2492@angus-think.wlc.globallogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 09/04/2015 10:48, Vadim Kochan a =E9crit :
> On Thu, Apr 09, 2015 at 10:30:14AM +0200, Nicolas Dichtel wrote:
[snip]
>> +struct nsid_cache {
>> +	struct hlist_node	nsid_hash;
>> +	struct hlist_node	name_hash;
>> +	int			nsid;
>> +	char			name[NAME_MAX];
>> +};
>
> I am not sure but may be lib/names.c can be used here for caching
> netns (name,id) entries here ?
If I understrand well, the way to get the id is completely different, t=
hus
it needs a lot of changes to use this lib.
