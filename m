From: Jesper Krogh <jesper@krogh.cc>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Sat, 10 May 2008 08:22:43 +0200
Message-ID: <48253F33.3000109@krogh.cc>
References: <86802c440805071130m62c1f4edydb3316dac4a2aba2@mail.gmail.com> <20080507.141521.193714938.davem@davemloft.net> <482498D5.9060008@krogh.cc> <20080509.143229.174354251.davem@davemloft.net> <4824C936.9000103@krogh.cc> <4824CE43.8060203@hp.com> <4824D4C0.10201@krogh.cc> <1210374525.21330.6.camel@lap75545.ornl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, yhlu.kernel@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Dillow <dillowda@ornl.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:36182 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751037AbYEJGWr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 May 2008 02:22:47 -0400
In-Reply-To: <1210374525.21330.6.camel@lap75545.ornl.gov>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Dillow wrote:
> lspci -vvv on the slot can tell you what has been negotiated. Also, you
> can figure the effective PCIe bandwidth using ~200 MB/s as a rule of
> thumb, given the various overheads on the bus. So an x4 won't fully load
> up a 10Gbps link.

Ok. It must be x8 then:
                 Link: Supported Speed 2.5Gb/s, Width x8, ASPM L0s, Port 1

-- 
Jesper
