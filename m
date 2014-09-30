From: Cong Wang <cwang@twopensource.com>
Subject: Why include/net/tcp_states.h is not exported to user-space?
Date: Tue, 30 Sep 2014 11:12:04 -0700
Message-ID: <CAHA+R7MDGKA1Z-1ytk8-+9XaKNcW+kG7UBn8drhdbLJeQYBCyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:47922 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751967AbaI3SMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 14:12:06 -0400
Received: by mail-wi0-f181.google.com with SMTP id hi2so579363wib.8
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 11:12:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

These states are needed for user-space to specify ->idiag_states.
Currently both libnl and ss make their own copy of these definitions.
Of course, new sock diag is not just limited to TCP, so we probably
need to rename them to SS_* before exporting them.

I can send a patch if you agree.

Thanks!
