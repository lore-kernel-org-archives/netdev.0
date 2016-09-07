From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: ptp
Date: Wed, 7 Sep 2016 23:12:23 +0200
Message-ID: <20160907211223.GA31741@localhost.localdomain>
References: <d1b2b740-8cc6-bf4a-722b-7b323fb0c7c0@cisco.com>
 <20160907204818.GA7470@localhost.localdomain>
 <85389e04-76ad-9a19-2a33-d49a9bdd8452@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xe-kernel@external.cisco.com" <xe-kernel@external.cisco.com>,
        "Shabeena Shabeena -X (sshabeen - ARICENT TECHNOLOGIES MAURIITIUS
        LIMITED at Cisco)" <sshabeen@cisco.com>
To: Daniel Walker <danielwa@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:38083 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752030AbcIGVM3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 17:12:29 -0400
Received: by mail-wm0-f51.google.com with SMTP id 1so54757892wmz.1
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 14:12:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <85389e04-76ad-9a19-2a33-d49a9bdd8452@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 07, 2016 at 01:55:19PM -0700, Daniel Walker wrote:
> So the code only allows second granularity negative updates,

No.

> or the seconds
> component is the only part which needs to actually be negative ?

Yes.

See the function, clockadj_step, in linuxptp/clockadj.c for a working
user space example.

Thanks,
Richard
