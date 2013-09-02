From: ke wang <hacklinux66@gmail.com>
Subject: confusion about tkey_extract_bits, please help.
Date: Mon, 2 Sep 2013 11:46:53 +0800
Message-ID: <CA+NCTVodoJFT2C=QXM873PoTVvUWZ10GzGrkGhDKqSUzi3rt+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: hacklinux66@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:45205 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757992Ab3IBDqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Sep 2013 23:46:54 -0400
Received: by mail-ob0-f173.google.com with SMTP id ta17so4027463obb.18
        for <netdev@vger.kernel.org>; Sun, 01 Sep 2013 20:46:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi:

  i had a question about ipv6 routing in 2.6.39. what the algorithm of
the function tkey_extract_bits. can anyone give me some advice on it,
thank u indeed .


static inline t_key tkey_extract_bits(t_key a, unsigned int offset,
unsigned int bits)
{
    if (offset < KEYLENGTH)
        return ((t_key)(a << offset)) >> (KEYLENGTH - bits);
    else
        return 0;
}
