From: Ilya Matveychikov <matvejchikov@gmail.com>
Subject: A couple of questions about the SKB fragments
Date: Thu, 5 May 2016 10:40:01 +0300
Message-ID: <CAKh5naYrZtf5y_Qw93G+GbxRVucsk4nbuiaguHcghtKEL=yQBw@mail.gmail.com>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Aleksey.Baulin@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:33270 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753216AbcEEHkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 03:40:22 -0400
Received: by mail-oi0-f47.google.com with SMTP id v145so93583406oie.0
        for <netdev@vger.kernel.org>; Thu, 05 May 2016 00:40:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello folks,

While working with fragmented SKBs we've got stuck with the following:
- is it possible for an SKB fragment in skb_shinfo(skb)->frag_list to
be fragmented too (i.e. to have SKBs in frag_list)?
- do skb->len and skb->data_len contain the whole SKB length,
including the length of all fragments (not only the paged parts)?

Is there any docs except the kernel sources itself to refer to?

Thanks.
