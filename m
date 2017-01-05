From: "Jonathan T. Leighton" <jtleight@udel.edu>
Subject: TCP using IPv4-mapped IPv6 address as source
Date: Thu, 5 Jan 2017 16:25:26 -0500
Message-ID: <87f4e2ec-22bf-2401-8401-57205f893289@udel.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f169.google.com ([209.85.216.169]:36056 "EHLO
        mail-qt0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753313AbdAEVZ2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 16:25:28 -0500
Received: by mail-qt0-f169.google.com with SMTP id k15so292531212qtg.3
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2017 13:25:28 -0800 (PST)
Received: from iMac-27.local ([2601:183:4102:810d:ad2f:5483:cbde:c0b])
        by smtp.gmail.com with ESMTPSA id x17sm35081650qka.34.2017.01.05.13.25.27
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 13:25:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've observed TCP using an IPv4-mapped IPv6 address as the source 
address, which I believe contradicts 
https://tools.ietf.org/html/rfc6890#page-14 (BCP 153). This occurs when 
an IPv6 TCP socket, bound to a local IPv4-mapped IPv6 address, attempts 
to connect to a remote IPv6 address. Presumable connect() should return 
EAFNOSUPPORT in this case. Please advise me if this is not to 
appropriate list to report this.

$ uname -a
Linux ubuntu 4.4.0-57-generic #78-Ubuntu SMP Fri Dec 9 23:50:32 UTC 2016 
x86_64 x86_64 x86_64 GNU/Linux

Best regards,
Jon
