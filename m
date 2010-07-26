From: Neshama Parhoti <pneshama@gmail.com>
Subject: lock_sock or sock_hold ?
Date: Mon, 26 Jul 2010 17:00:15 +0300
Message-ID: <AANLkTim7LQ65RWvy+TQ+HtwjJM89zt4g12H6mFinQT0v@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:63824 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751418Ab0GZOAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 10:00:18 -0400
Received: by bwz1 with SMTP id 1so2798299bwz.19
        for <netdev@vger.kernel.org>; Mon, 26 Jul 2010 07:00:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hello everyone,

can you please be kind and help me understand the differences between
lock_sock and sock_hold ?

i can see that lock_sock takes a spin lock (bh) to mark owned = 1, and
then takes a mutex, whereas sock_hold only increases the atomic
refcnt.

but how do i know which of them I should use ?

i'm puzzled as to when should those two different APIs be used..

thank you a lot
~pnesh
