From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [PATCH 16/18] e1000: add dynamic itr modes
Date: Wed, 1 Nov 2006 13:55:44 -0800
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F520118DC37@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Rick Jones" <rick.jones2@hp.com>,
	"Robin Humble" <rjh@cita.utoronto.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:5567 "EHLO mga01.intel.com")
	by vger.kernel.org with ESMTP id S1752496AbWKAVzw convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Nov 2006 16:55:52 -0500
Content-class: urn:content-classes:message
To: "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Garzik, Jeff" <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Add a new dynamic itr algorithm, with 2 modes, and make it the default
> operation mode. This greatly reduces latency and increases small
> packet performance, at the "cost" of some CPU utilization. Bulk
> traffic throughput is unaffected.

Thanks to the generous testing of Rick Jones from HP, we have some
externally published numbers to back up this patch. Please see the
updated paper at
ftp://ftp.cup.hp.com/dist/networking/briefs/nic_latency_vs_tput.txt or
http://tinyurl.com/yd2ufj

We would also like to thank Robin Humble for his feedback and input on
this patch.

Testing and comments welcome, particularly from anyone running latency
sensitive testing, where they might want to test with the
"InterruptThrottleRate=1" module parameter.

Jesse
