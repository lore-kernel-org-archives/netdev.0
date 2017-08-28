From: Alexander Aring <aring@mojatatu.com>
Subject: [PATCH iproute2 0/4] tc: m_ife: handle IFE ethertype value
Date: Mon, 28 Aug 2017 15:07:34 -0400
Message-ID: <20170828190738.26829-1-aring@mojatatu.com>
Cc: yotamg@mellanox.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        netdev@vger.kernel.org, Alexander Aring <aring@mojatatu.com>
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35003 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751488AbdH1TIo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 15:08:44 -0400
Received: by mail-io0-f194.google.com with SMTP id c18so1102231ioj.2
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 12:08:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this patch series fix some ife type handling for example it allows to set
ethertype to zero and prints IFE type like IEE specification.

Also it will report about the new introduced IFE type as fallback if no
IFE type as parameter is given. This new behaviour is also added to the
manpage of tc-ife.

Note: Please wait until the related kernel patches comes in. This
patch series contains an UAPI change which need to be accepted by netdev
at first. Thanks.

- Alex

Alexander Aring (4):
  tc: m_ife: allow ife type to zero
  tc: m_ife: print IEEE ethertype format
  tc: m_ife: report about kernels default type
  man: tc-ife: add default type note

 man/man8/tc-ife.8 | 2 +-
 tc/m_ife.c        | 8 ++++++--
 2 files changed, 7 insertions(+), 3 deletions(-)

-- 
2.11.0
