From: Terry <hanfang@baidu.com>
Subject: performance issue of netdev_budget and dev_weight with ixgbe
Date: Fri, 20 Mar 2009 16:48:25 +0800
Message-ID: <49C35859.7050803@baidu.com>
References: <a06240409c5d5e74a49d0@[129.98.90.227]> <F169D4F5E1F1974DBFAFABF47F60C10A1E6EABF2@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.baidu.com ([61.135.163.61]:33395 "HELO smtp.baidu.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753201AbZCTIzL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2009 04:55:11 -0400
In-Reply-To: <F169D4F5E1F1974DBFAFABF47F60C10A1E6EABF2@orsmsx507.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesse,
I was doing some tuning work for ip-forwarding with oplin cards .
i found that when i set netdev_budget to 64(default is 300),just the 
same as  dev_weight in ixgbe, i got the highest forwarding rate.
not only in forwarding scenario, but also the  "receive and send back" 
scenario.
If I change  netdev_budget or weight in driver to any other value, the 
performace get worse.
how did the ixgbe driver folks pick  the  value of 64 and how does it 
affect the perf?

thanks & rgds
terry




