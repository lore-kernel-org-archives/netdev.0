From: Eduardo Panisset <eduardo.panisset@gmail.com>
Subject: Application brokne due to XFRMA_ALG_AUTH_TRUNC
Date: Tue, 4 Oct 2011 18:08:37 -0300
Message-ID: <CADsjWXR66C2SdfmLP0wqRvbcDJkXbYBN=zzTZLP5_+pE0fenqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:44441 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933618Ab1JDVIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2011 17:08:38 -0400
Received: by ywb5 with SMTP id 5so921044ywb.19
        for <netdev@vger.kernel.org>; Tue, 04 Oct 2011 14:08:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

I have an application compiled against kernel 2.6.32 and which is
using XFRMA_MARK (value 20).
However the same aplication does not work anymore on kernel 2.6.38.8
due to XFRMA_MARK has now the value 21 because of a new attribute
XFRMA_ALG_AUTH_TRUNC inserted before it in the file linux/xfrm.h.
Now the only solution would be recompiling this application. Is
correct introducing a new parameter in the middle of an existing enum
in the kernel headers ?


Rgds,
Eduardo Panisset.
