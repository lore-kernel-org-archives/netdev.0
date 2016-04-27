From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: ixgbe: cannot enable LRO
Date: Wed, 27 Apr 2016 08:37:14 -0700
Message-ID: <CAKgT0UceTxomp+Zf5ks_B0bFomdx2jyhWLwSXh4716voJ5YFAg@mail.gmail.com>
References: <20160427093646.GA15205@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, Jirka Hladky <jhladky@redhat.com>,
	Adam Okuliar <aokuliar@redhat.com>
To: Otto Sabart <osabart@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:34329 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753181AbcD0PhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 11:37:16 -0400
Received: by mail-io0-f169.google.com with SMTP id 190so44334309iow.1
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 08:37:15 -0700 (PDT)
In-Reply-To: <20160427093646.GA15205@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 27, 2016 at 2:36 AM, Otto Sabart <osabart@redhat.com> wrote:
>
> Hello everyone,
> does anybody have a problem with LRO on ixge (on latest 4.6-rc5)?
> I cannot find a way to enable it.
>
> On stable RHEL7.2 kernel everything works fine.
>
> I opened a bug report [0].
>
> [0] https://bugzilla.kernel.org/show_bug.cgi?id=117291
>
>
> Thanks!
>
> Ota

So I am able to turn on LRO without any issues.

Do you know if you have done anything that might disable LRO such as
modified the rx-usecs to a value less than 10 or enabled routing or
bridging on the device?  Also I think a stacked device might be able
to block you from enabling LRO unless all the devices stacked on the
interface can support it.

- Alex
