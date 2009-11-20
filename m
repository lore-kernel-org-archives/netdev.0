From: "Govindarajan, Sriramakrishnan" <srk@ti.com>
Subject: Compile Error for TI Davinci
Date: Fri, 20 Nov 2009 17:36:38 +0530
Message-ID: <FCCFB4CDC6E5564B9182F639FC35608702FA751A01@dbde02.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davinci-linux-open-source@linux.davincidsp.com"
	<davinci-linux-open-source@linux.davincidsp.com>,
	"Subrahmanya, Chaithrika" <chaithrika@ti.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:58296 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751887AbZKTMGk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 07:06:40 -0500
Received: from dbdp20.itg.ti.com ([172.24.170.38])
	by bear.ext.ti.com (8.13.7/8.13.7) with ESMTP id nAKC6igu027404
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 20 Nov 2009 06:06:46 -0600
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


David,

Patch for "TI DaVinci EMAC: Clear statistics register properly"(commit- 0fe7463a35aadfaf22d1ca58325ab3851b8d757c on net-next) has dependency on 
Patch "TI DaVinci EMAC: Minor macro related updates "(commit - 69ef9694099802f7feeb23182dfb869e7c5f76f0 on net-next).

The first patch has been pushed upstream while the later still remains on
Net-next. Due to the dependency between these two, we are seeing compilation 
Failure when we build for Davinci.

Can you please push "TI DaVinci EMAC: Minor macro related updates" - 69ef9694099802f7feeb23182dfb869e7c5f76f0 up-stream .

Regards
Sriram

