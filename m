From: Vadim Kochan <vadim4j@gmail.com>
Subject: iproute2:tc: Class names
Date: Mon, 2 Mar 2015 00:19:56 +0200
Message-ID: <20150301221956.GA25284@angus-think.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:45989 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753652AbbCAWbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 17:31:20 -0500
Received: by wibbs8 with SMTP id bs8so10951547wib.4
        for <netdev@vger.kernel.org>; Sun, 01 Mar 2015 14:31:19 -0800 (PST)
Received: from angus-think.lan (121-43-207-82.ip.ukrtel.net. [82.207.43.121])
        by mx.google.com with ESMTPSA id fa3sm13365998wib.17.2015.03.01.14.31.18
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Mar 2015 14:31:18 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have some local version of tc which can show class names in the
following manners (-m means use names mapping):

# tc/tc -m class show dev lo

class htb 1:10 parent 1:1 leaf 10: prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b 
class htb 1:1 root rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b 
class htb web:1:20 parent 1:1 leaf 20: prio 0 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b 
class htb voip:1:40 parent 1:2 leaf 40: prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b 
class htb 1:50 parent 1:2 leaf 50: prio 0 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b 

It uses special mapping file from /etc/iproute2/cls_map:

1:20    web
1:40    voip

Also it can be used for specifying class name for filter.

What do you think about this ?

Thanks,
