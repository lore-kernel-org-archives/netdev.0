From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next PATCH 3/6] i40e: Sync link state between VFs and VFPRs
Date: Fri, 30 Dec 2016 17:43:10 +0200
Message-ID: <CAJ3xEMiQaVc=aJMFJdWEDHEeYL5NnxAcqbM_cTa+X5CkNrLtZg@mail.gmail.com>
References: <1483078863-22026-1-git-send-email-sridhar.samudrala@intel.com> <1483078863-22026-4-git-send-email-sridhar.samudrala@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Anjali Singhai Jain <anjali.singhai@intel.com>,
        jakub.kicinski@netronome.com, intel-wired-lan@lists.osuosl.org,
        Linux Netdev List <netdev@vger.kernel.org>
To: Sridhar Samudrala <sridhar.samudrala@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:33650 "EHLO
        mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752421AbcL3PnL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2016 10:43:11 -0500
Received: by mail-oi0-f45.google.com with SMTP id 128so231352390oig.0
        for <netdev@vger.kernel.org>; Fri, 30 Dec 2016 07:43:11 -0800 (PST)
In-Reply-To: <1483078863-22026-4-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 30, 2016 at 8:21 AM, Sridhar Samudrala
<sridhar.samudrala@intel.com> wrote:

[..]
> - enable/disable VF link state via ndo_set_vf_link_state will update the
>   admin state of associated VFPR.

why you want to do that? anything missing here w.o using the legacy mode?
