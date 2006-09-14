From: mabbas <mabbas@linux.intel.com>
Subject: [d80211] connecting to B-mode AP
Date: Thu, 14 Sep 2006 16:24:46 -0700
Message-ID: <4509E4BE.40001@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:25893 "EHLO
	azsmga101.ch.intel.com") by vger.kernel.org with ESMTP
	id S932118AbWINXYn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Sep 2006 19:24:43 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When I connect to b-mode only AP and then run iwconf it shows it as a 
G-mode AP. I guess when we set frequency it look through all the modes 
and set the mode to the first channel it founds. since B and G share the 
same frequencies it will set phymode to G. How can we force it to set 
phymode to the AP we are associating with.
