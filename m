From: Rafa Corvillo <rafael.corvillo@aoifes.com>
Subject: Re: [ISSUE: sky2 - rx error] Link stops working under heavy traffic
 load connected to a mv88e6176
Date: Fri, 26 May 2017 12:13:03 +0200
Message-ID: <5927FFAF.40301@aoifes.com>
References: <20170427130450.GL17172@lunn.ch> <59032D8B.1010801@aoifes.com>
 <20170428122259.GH13231@lunn.ch> <59105EA3.9030203@aoifes.com>
 <20170508123852.GI27709@lunn.ch> <591AD990.901@aoifes.com>
 <20170516124759.GB27959@lunn.ch> <591AF9FD.1000304@aoifes.com>
 <20170516132116.GE5456@lunn.ch> <591B1FC2.1090402@aoifes.com>
 <20170516155843.GE32357@lunn.ch> <591B267D.1030800@aoifes.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-relay-03-3.dondominio.net ([31.214.176.46]:38664 "EHLO
        smtp-relay-03-3.dondominio.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1764256AbdEZKNH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 06:13:07 -0400
In-Reply-To: <591B267D.1030800@aoifes.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As modifying sky2 code I have not could get any solution, then I have 
modified some parameters on the ethernet interface and using a MTU = 
1503 and disabling TSO (TCP Segmentation Offload) mechanism all 
communication errors disappear, both the rx errors due to too long 
packets and tx timeout errors. I have performed iperf tests during 1 
hour (downstream and upstream) and the performance of the ethernet is 
stable. Furthermore, disabling SG (scatter-gather) improves the 
throughput of the ethernet interface with traffic upstream.

Is it possible that these offload mechanism don't work fine with the 
sky2 driver?

Thanks,

Rafa
