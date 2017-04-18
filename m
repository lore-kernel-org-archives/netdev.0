From: Code Soldier1 <codesoldier1@gmail.com>
Subject: question about size of sk_buff and skb_shared_info
Date: Tue, 18 Apr 2017 10:34:08 -0700
Message-ID: <CABGNecyP8tpBtbOPL_4fyhqnkTYEa80sHCuDrUJdm9gxihFX6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:34419 "EHLO
        mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753636AbdDRReJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 13:34:09 -0400
Received: by mail-io0-f175.google.com with SMTP id a103so5297183ioj.1
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 10:34:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Folks,

I am sure there is a reason for the current sizes of these structures,
However the reason is not obvious to me. So please help me understand.

Currently the size of sk_buff on an x86_64 system is 232 bytes -- Why
is that. I expected it to be a multiple of 32/64 as they are the most
common cache lines. Since the alignment calculation will align the
structure with the hw cache line, it seems like we might be wasting
space ?

skb_shared_info on the other hand is perfectly aligned with a size of 320 bytes.

Thanks,

-- 
CS1
