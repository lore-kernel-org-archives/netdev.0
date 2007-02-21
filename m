From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: [PATCH] ehea: dynamic add / remove port
Date: Wed, 21 Feb 2007 08:38:24 +0100
Message-ID: <200702210838.24515.ossthema@de.ibm.com>
References: <200702201828.20808.ossthema@de.ibm.com> <1171994215.22669.8.camel@sinatra.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Klein <osstklei@de.ibm.com>, stefan.roscher@de.ibm.com,
	Christoph Raisch <RAISCH@de.ibm.com>,
	Marcus Eder <MEDER@de.ibm.com>, netdev <netdev@vger.kernel.org>
To: John Rose <johnrose@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:6608 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161117AbXBUHnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 02:43:31 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id l1L7hUld106382
	for <netdev@vger.kernel.org>; Wed, 21 Feb 2007 07:43:30 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1L7hUfK499730
	for <netdev@vger.kernel.org>; Wed, 21 Feb 2007 08:43:30 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1L7hTlw013566
	for <netdev@vger.kernel.org>; Wed, 21 Feb 2007 08:43:30 +0100
In-Reply-To: <1171994215.22669.8.camel@sinatra.austin.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> This looks great!  Two questions.  I would assume that the of_device
> results in a "devspec" file in the sysfs directory for the port?  Also,

yes, that is true. There is a devspec file containing the ofdt path in the
port directory.

> is there a way to correlate a logical port to an ethernet interface
> (eth0, etc)?

This is also included. Each logical port has a symbolic link to ethX, done
with the SET_NETDEV_DEV macro.

Regards,
Jan-Bernd


