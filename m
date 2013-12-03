From: Kevin Wallace <kevin@pentabarf.net>
Subject: Re: [PATCH v2] macvlan: Support creating macvtaps from macvlans
Date: Tue, 3 Dec 2013 09:46:53 -0800
Message-ID: <CAEQCv+aNKfxYWKBn40QoUHBEB41_N_TadxuQB0-raDMxu-Cq6A@mail.gmail.com>
References: <1386043991-4372-1-git-send-email-kevin@pentabarf.net>
 <1386068122-12039-1-git-send-email-kevin@pentabarf.net> <529E0421.2090504@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Michal Kubecek <mkubecek@suse.cz>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:56491 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754333Ab3LCRrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 12:47:16 -0500
Received: by mail-qc0-f175.google.com with SMTP id e9so2336541qcy.6
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 09:47:13 -0800 (PST)
In-Reply-To: <529E0421.2090504@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 3, 2013 at 8:17 AM, Vlad Yasevich <vyasevich@gmail.com> wrote:
> the other question is should this be done in a loop?  What happens if
> you have nested namespaces?

I don't believe that will change anything -- this code makes the
situation necessary for multiple iterations (macvlan with a macvlan
lower) impossible.
