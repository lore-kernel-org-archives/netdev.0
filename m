From: Eduardo Panisset <eduardo.panisset@gmail.com>
Subject: Is __xfrm_lookup always on non-atomic context ?
Date: Tue, 12 Apr 2011 02:58:52 -0300
Message-ID: <BANLkTimZdNROJdMu0sHrNn_Rt0vyKqFSOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:42325 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752959Ab1DLF6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 01:58:53 -0400
Received: by vws1 with SMTP id 1so4809198vws.19
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2011 22:58:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I'm using XFRM for tunneling payload traffic on Dual Stack Mobility application.
However, if correspondent XFRM states to XFRM policy's templates have
not been registered yet, It's possible the current process wait for
them, using a wait queue.
But what if this function is not being called on atomic context (e.g. softirq) ?

Thanks in advance,
Eduardo Panisset.
