From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] ehea: Optional TX/RX path optimized for SMP
Date: 03 Mar 2007 04:06:08 +0100
Message-ID: <p73mz2vauvz.fsf@bingen.suse.de>
References: <200702231730.58579.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36666 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992900AbXCCCGc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 21:06:32 -0500
In-Reply-To: <200702231730.58579.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan-Bernd Themann <ossthema@de.ibm.com> writes:
> 
> Are there any concerns about this approach?

Yes. You should fix the NAPI code instead of trying to work
around it.

-Andi
