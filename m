From: Michael Rossberg <michael.rossberg@tu-ilmenau.de>
Subject: Question about NBMA tunnels for IPv6
Date: Thu, 29 Aug 2013 11:03:56 +0200
Message-ID: <016C7C5A-5FCD-44C6-99CF-B730A0291B61@tu-ilmenau.de>
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wega.rz.tu-ilmenau.de ([141.24.4.159]:39206 "EHLO
	wega.rz.tu-ilmenau.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755578Ab3H2JLA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 05:11:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everybody,

Linux offers a so-called NBMA mode for IPv4 tunnels, i.e., one can set the destination 
address of a tunnel to 0.0.0.0 and specify the destination on a per packet basis using 
the gateway field in routes. For IPv6 tunnels this option seems to be non existing. 
Thus, a distinguished tunnel device has to be added for each possible endpoint. 
In scenarios with many endpoints this does not scale too well.

Is there any reason for NBMA mode to be not present for v6 (except nobody having
the time to implement it)? If no - is there anything special to look at in order to get 
such a feature upstream?
Thanks,

Mick