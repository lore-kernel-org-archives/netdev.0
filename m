From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Performance regression on kernels 3.10 and newer
Date: Mon, 18 Aug 2014 08:29:41 -0700
Message-ID: <53F21BE5.1030605@hp.com>
References: <53ECFDAB.5010701@intel.com>	<1408041962.6804.31.camel@edumazet-glaptop2.roam.corp.google.com>	<53ED4354.9090904@intel.com>	<20140814.162024.2218312002979492106.davem@davemloft.net>	<53EE4023.6080902@intel.com>	<CA+mtBx_aEe6SvWV6tfqzGWcPvVM+FE6kbnyFE5FbECU9HN7EXg@mail.gmail.com>	<53EE5B25.3040206@intel.com> <CA+mtBx-LZgnpWAf3Jn0htoga32UaMc-NAqURmXezmZmwg2oGRQ@mail.gmail.com> <53EE967F.9090101@intel.com> <063D6719AE5E284EB5DD2968C1650D6D1747969E@AcuExch.aculab.com> <53F21A38.50905@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t2354.austin.hp.com ([15.217.128.53]:24907 "EHLO
	g2t2354.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834AbaHRP3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2014 11:29:44 -0400
In-Reply-To: <53F21A38.50905@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alex -

Why don't you go ahead and shoot me a patch to netperf to conditionally 
put a poll() or select() in front of receive.  I guess the "omni" code 
would be the place to do it.  The netperf-talk or netperf-dev lists 
would be the place to send it I suspect.

happy benchmarking,

rick jones
