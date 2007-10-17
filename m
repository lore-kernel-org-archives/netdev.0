From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: multicast: bug or "feature"
Date: Wed, 17 Oct 2007 16:11:25 -0700
Message-ID: <OFD60CD2B7.B3E2F68F-ON88257377.007EFD45-88257377.007F4B08@us.ibm.com>
References: <47167DD4.3020108@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Brian Haley <brian.haley@hp.com>, netdev <netdev@vger.kernel.org>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:33009 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755785AbXJQXLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 19:11:31 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9HNBSVk018856
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 19:11:28 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9HNBSdu106750
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 17:11:28 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9HNBSjH026194
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 17:11:28 -0600
In-Reply-To: <47167DD4.3020108@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

You're joining the group on interface eth1, which is the
sender, right? You need to be a member on eth0 to receive it
there. I think your program needs another argument, to
specify the receiving interface, which you want to be
different from the sending interface.

                                        +-DLS

