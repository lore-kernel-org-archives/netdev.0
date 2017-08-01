From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH RFC, iproute2] tc/mirred: Extend the mirred/redirect
 action to accept additional traffic class parameter
Date: Mon, 31 Jul 2017 20:51:33 -0700
Message-ID: <20170731205133.5e58e47c@xeon-e3>
References: <150154805003.4819.12498976860683140342.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@intel.com,
        kiran.patil@intel.com, sridhar.samudrala@intel.com,
        mitch.a.williams@intel.com, alexander.duyck@gmail.com,
        neerav.parikh@intel.com, carolyn.wyborny@intel.com,
        jeffrey.t.kirsher@intel.com
To: Amritha Nambiar <amritha.nambiar@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:37288 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751776AbdHADvg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 23:51:36 -0400
Received: by mail-pg0-f50.google.com with SMTP id y129so2550438pgy.4
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 20:51:36 -0700 (PDT)
In-Reply-To: <150154805003.4819.12498976860683140342.stgit@anamdev.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 31 Jul 2017 17:40:50 -0700
Amritha Nambiar <amritha.nambiar@intel.com> wrote:
The concept is fine, bu t the code looks different than the rest which
is never a good sign.


> +				if ((argc > 0) && (matches(*argv, "tc") == 0)) {

Extra () are unnecessary in compound conditional.

> +					tc = atoi(*argv);

Prefer using strtoul since it has better error handling than atoi()

> +					argc--;
> +					argv++;
> +				}


Use NEXT_ARG() construct like rest of the code.
