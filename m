From: Matthias Rosenfelder <mrosenfelder.lkml@gmail.com>
Subject: [RFC] tls: length check correct in do_tls_getsockopt_tx()?
Date: Wed, 5 Jul 2017 03:10:53 -0400
Message-ID: <a0dac911-6401-12cb-611c-5a1723d943c1@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, dan.carpenter@oracle.com, davejwatson@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:33149 "EHLO
        mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752093AbdGEHK7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 03:10:59 -0400
Received: by mail-yw0-f194.google.com with SMTP id f200so12788774ywb.0
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2017 00:10:59 -0700 (PDT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

In do_tls_getsockopt_tx():

if (len == sizeof(crypto_info)) {

should be

if (len == sizeof(*crypto_info)) {

as crypto_info is of pointer type. Or am I missing something?


btw: I am not very familiar with sockets. So I am wondering
what is the use of this functionality? Why copy only the header
to userspace?


Thanks.
Best Regards,

Matthias
