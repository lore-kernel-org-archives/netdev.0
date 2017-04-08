From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH] net: netfilter: Replace explicit NULL comparisons
Date: Sat, 8 Apr 2017 20:21:56 +0200 (CEST)
Message-ID: <nycvar.YFH.7.76.1704082020530.14011@n3.vanv.qr>
References: <20170408172113.GA9352@arushi-HP-Pavilion-Notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: pablo@netfilter.org, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arushi Singhal <arushisinghal19971997@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a3.inai.de ([88.198.180.161]:59994 "EHLO a3.inai.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751166AbdDHSV7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 8 Apr 2017 14:21:59 -0400
In-Reply-To: <20170408172113.GA9352@arushi-HP-Pavilion-Notebook>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 2017-04-08 19:21, Arushi Singhal wrote:

>Replace explicit NULL comparison with ! operator to simplify code.

I still wouldn't do this, for the same reason as before. Comparing to 
NULL explicitly more or less gave an extra guarantee that the other 
operand was also a pointer.
