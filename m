From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v3] rocker: add debugfs support to dump internal
 tables
Date: Tue, 18 Aug 2015 09:52:49 +0200
Message-ID: <20150818075249.GC2200@nanopsycho.orion>
References: <1439850977-31079-1-git-send-email-sfeldma@gmail.com>
 <20150818055555.GA2200@nanopsycho.orion>
 <CAE4R7bDy4zQ9=20Q6su+q4+kb+B25Kk7MOZyuEbBLBv9YSdnFA@mail.gmail.com>
 <20150818064829.GB2200@nanopsycho.orion>
 <CAE4R7bCKMzfi0b4ZpDeFpaRpDJzZemU=kmKXO3C96yK=wgc_UA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:35435 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751282AbbHRHww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 03:52:52 -0400
Received: by wicne3 with SMTP id ne3so88027768wic.0
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 00:52:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bCKMzfi0b4ZpDeFpaRpDJzZemU=kmKXO3C96yK=wgc_UA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Aug 18, 2015 at 09:21:15AM CEST, sfeldma@gmail.com wrote:
>On Mon, Aug 17, 2015 at 11:48 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Tue, Aug 18, 2015 at 08:14:48AM CEST, sfeldma@gmail.com wrote:
>>>On Mon, Aug 17, 2015 at 10:55 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>> Tue, Aug 18, 2015 at 12:36:17AM CEST, sfeldma@gmail.com wrote:
>>>>>From: Scott Feldman <sfeldma@gmail.com>
>>>>
>>>> <snip>
>>>>
>>>>>+      rocker->dbg_dir = debugfs_create_dir(dbg_dir_name, rocker_dbg_root);
>>>>>+      if (!rocker->dbg_dir)
>>>>
>>>> You still check the retval here and
>>>
>>>It's OK.  See include/linux/debugfs.h when CONFIG_DEBUG_FS=n.
>>>debugfs_create_dir() returns ERR_PTR(-ENODEV), which is !NULL.
>>
>> Does not make sense to check it for NULL then. It is never NULL...
>
>It can be NULL when CONFIG_DEBUG_FS=y.

You are right, this inconsistency looks odd to me though.

Anyway,

Acked-by: Jiri Pirko <jiri@resnulli.us>
