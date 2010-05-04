From: Bhaskar Dutta <bhaskie@gmail.com>
Subject: TCP-MD5 checksum failure on x86_64 SMP
Date: Tue, 4 May 2010 09:00:34 +0530
Message-ID: <o2h571fb4001005032030tdf02a4fag520ec4e56ebdb8df@mail.gmail.com>
References: <i2h571fb4001005031027y4a58c4dtfd28ddcdc08d8401@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f204.google.com ([209.85.222.204]:41086 "EHLO
	mail-pz0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753866Ab0EDDae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 23:30:34 -0400
Received: by pzk42 with SMTP id 42so545690pzk.4
        for <netdev@vger.kernel.org>; Mon, 03 May 2010 20:30:34 -0700 (PDT)
In-Reply-To: <i2h571fb4001005031027y4a58c4dtfd28ddcdc08d8401@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am observing intermittent TCP-MD5 checksum failures
(CONFIG_TCP_MD5SIG)  on kernel 2.6.31 while talking to a BGP router.

The problem is only seen in multi-core 64 bit machines.
Is there any known bug in the per_cpu_ptr implementation (I am aware
that the percpu allocator has been re-implemented in 2.6.33) that
might cause a corruption in 64 bit SMP machines?

Any pointers would be appreciated.

Thanks,
Bhaskar
