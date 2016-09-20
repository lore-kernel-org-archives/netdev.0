From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 3/6] ip xfrm state: add save/restore
Date: Tue, 20 Sep 2016 09:43:31 -0700
Message-ID: <20160920094331.4a3c08de@xeon-e3>
References: <1472806946-16575-1-git-send-email-ptikhomirov@virtuozzo.com>
        <1472806946-16575-4-git-send-email-ptikhomirov@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Konstantin Khorenko <khorenko@virtuozzo.com>,
        crml <criu@openvz.org>
To: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34177 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932124AbcITQnV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 12:43:21 -0400
Received: by mail-pf0-f170.google.com with SMTP id p64so9121742pfb.1
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 09:43:21 -0700 (PDT)
In-Reply-To: <1472806946-16575-4-git-send-email-ptikhomirov@virtuozzo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  2 Sep 2016 12:02:23 +0300
Pavel Tikhomirov <ptikhomirov@virtuozzo.com> wrote:

> +static __u32 state_dump_magic = 0x71706987;
> +
> +static int xfrm_state_list_deleteall_or_save(int argc, char **argv, int deleteall, int save)

I have no problem with the overall functionality of this patch set, but this
function_name_is_too_long_for_rational_humans.

Please make the function names (especially the local static ones) shorter and more reasonable
and resubmit
