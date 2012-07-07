From: Lin Ming <mlin@ss.pku.edu.cn>
Subject: Question: eth0 and wlan0 traffic load
Date: Sat, 7 Jul 2012 11:28:36 +0800
Message-ID: <CAF1ivSaY3s-Vjbe7_vziCRCEsaXduug3+2G9R55SUBQ8HPT6hQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [124.207.24.138] ([124.207.24.138]:42804 "EHLO
	mail.ss.pku.edu.cn" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751196Ab2GGD3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 23:29:13 -0400
Received: from mail-vb0-f46.google.com (mail-vb0-f46.google.com [209.85.212.46])
	(Authenticated sender: mlin@ss.pku.edu.cn)
	by mail.ss.pku.edu.cn (Postfix) with ESMTPA id 9EF42DBC5C
	for <netdev@vger.kernel.org>; Sat,  7 Jul 2012 11:28:39 +0800 (CST)
Received: by vbbff1 with SMTP id ff1so6528342vbb.19
        for <netdev@vger.kernel.org>; Fri, 06 Jul 2012 20:28:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Host1
  eth0: 192.168.1.102
wlan0: 192.168.1.103

On Host2, scp a file to Host1 via wlan0
# scp tmp.file 192.168.1.103:/tmp

But ifstat shows all traffic goes to eth0.
Why does kernel choose eth0 although I use wlan0's address?
Is this an intended behavior?

       eth0               wlan0
 KB/s in  KB/s out   KB/s in  KB/s out
11989.26    286.05      0.00      0.00
11998.90    286.00      0.00      0.00
 6910.18    170.63      0.00      0.00
10260.05    246.82      0.00      0.00
 8295.90    202.12      0.00      0.00
11979.90    282.41      0.00      0.00
11618.39    274.71      0.00      0.00
 7004.78    170.79      0.00      0.00
12003.33    286.21      0.00      0.00
 7775.28    190.59      0.00      0.00
11980.18    280.76      0.00      0.00
11998.32    286.29      0.00      0.00
11995.61    286.08      0.00      0.00
11996.57    285.88      0.00      0.00
 6938.20    162.98      0.00      0.00
 6736.30    169.22      0.04      0.00
12000.92    284.83      0.00      0.00
12005.41    286.13      0.00      0.00
12000.58    286.27      0.00      0.00
11963.65    284.13      0.00      0.00
11935.24    281.32      0.00      0.00
12002.83    286.27      0.00      0.00
11997.59    285.68      0.00      0.00

Thanks,
Lin Ming
