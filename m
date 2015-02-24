From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [RFC PATCH 01/29] fib_trie: Convert fib_alias to hlist from list
Date: Tue, 24 Feb 2015 23:52:50 +0200
Message-ID: <CAJ3xEMjnFb_ZFQ2ALU_QmGBY23hkYNY831kDnwYEbet+6-3YFg@mail.gmail.com>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
	<20150224204801.26106.10186.stgit@ahduyck-vm-fedora20>
	<CAJ3xEMhn6R9heFGtEB4-uxb2SHc2XWZv2oX_7pYhZVYZo5MeFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:59333 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752416AbbBXVwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 16:52:51 -0500
Received: by mail-ob0-f175.google.com with SMTP id va2so46619651obc.6
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 13:52:50 -0800 (PST)
In-Reply-To: <CAJ3xEMhn6R9heFGtEB4-uxb2SHc2XWZv2oX_7pYhZVYZo5MeFw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 24, 2015 at 11:51 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Tue, Feb 24, 2015 at 10:48 PM, Alexander Duyck
> <alexander.h.duyck@redhat.com> wrote:
>> There isn't any advantage to having it as a list and by making it an hlist
>> we make the fib_alias more compatible with the list_info in terms of the
>> type of list used.
>
> Hi Alex, twenty nine patches without (unless it's on his way) cover
> letter are really hard to grasp, can you write something general on
> this series, please...

Sorry for the spam, it's there.
