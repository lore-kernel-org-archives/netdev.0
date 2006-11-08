From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: 2.6.19-rc1: Volanomark slowdown
Date: Wed, 8 Nov 2006 13:07:08 +0300
Message-ID: <20061108100708.GA17357@ms2.inr.ac.ru>
References: <1162924354.10806.172.camel@localhost.localdomain> <20061107.124557.21592397.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tim.c.chen@linux.intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:65168 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S932142AbWKHKKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Nov 2006 05:10:30 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061107.124557.21592397.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hell]!

> > reduced Volanomark benchmark throughput by 10%.  

The irony of it is that java vm used to be one of victims
of over-delayed acks.

I will look, there is a little chance that it is possible
to detect the situation and to stretch ACKs.

There is one little question though. If you see a visible
difference in performance, does it mean that you see Volaconomark
used to show much better numbers comparing to another OSes? :-)

Alexey
