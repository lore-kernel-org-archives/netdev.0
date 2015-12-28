From: pavi1729 <pavitra1729@gmail.com>
Subject: skb_clone query
Date: Mon, 28 Dec 2015 19:48:24 +0530
Message-ID: <CAMf7+LgvSXpt98T5ty_yq-cZoGnRe5Hkz-5r7D3AyOwH27yxaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:38196 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912AbbL1OSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2015 09:18:24 -0500
Received: by mail-ig0-f173.google.com with SMTP id mw1so21770798igb.1
        for <netdev@vger.kernel.org>; Mon, 28 Dec 2015 06:18:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
  Just out of curisity, I was looking at Kernel 3.14, skb_clone
function in f_ncm.c

http://lxr.free-electrons.com/source/drivers/usb/gadget/f_ncm.c?v=3.14#L1063


QUERY : Shouldn't a kfree_skb(skb2); happen before goto err @1070 ?
              Is this not a memleak ?


1068           if (!skb_pull(skb2, index)) {
1069                         ret = -EOVERFLOW;
1070                         goto err;
1071           }


Thanks,
Pavi
