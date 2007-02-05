From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: NAPI quota and budget
Date: Mon, 5 Feb 2007 12:00:31 +0100
Message-ID: <17863.3663.723022.836914@robur.slu.se>
References: <b7dacee80702032234n5789e9b9n2dcf9239730d25b4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert.Olsson@data.slu.se
To: "K. Salah" <drsalah66@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:49101 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932085AbXBELSF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 06:18:05 -0500
Received: from robur.slu.se (robur.slu.se [130.238.98.12])
	by mx1.slu.se (8.13.7/8.13.6) with ESMTP id l15BI1j6013719
	for <netdev@vger.kernel.org>; Mon, 5 Feb 2007 12:18:01 +0100
In-Reply-To: <b7dacee80702032234n5789e9b9n2dcf9239730d25b4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello!

K. Salah writes:
 
 > I have a question about the quota per poll in NAPI.  Any idea how the
 > quota of 64 packets per poll per NIC was selected?  Why 64, not any
 > other number?  Is there science behind this number.

 The number comes from experimentation. The "science" is thats it's
 possible set any number at all.

 The first NAPI driver tulip (100 Mps) increased the RX-ringsize from 32 
 128 descriptors and used 16 pkts per poll.

 A quota of 64 for GIGE devices (tested with 256 descriptors) seemed to be 
 good compromise in experiments.  16 < 64 < netdev_budget 
  
 > And the same goes for the budget of 300?
 > 
 > Was that done based on expermintation?

 Yes it was the size of central buffer size before NAPI. It's possible
 the netdev_budget can be increased a bit today as the packet processing
 speed has increased.

 Cheers.
					--ro
