From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/2] ehea: Receive SKB Aggregation
Date: Thu, 31 May 2007 14:41:18 +0100
Message-ID: <20070531134118.GA30501@infradead.org>
References: <200705311354.56979.osstklei@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <ossthema@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <ossrosch@linux.vnet.ibm.com>
To: Thomas Klein <osstklei@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:42586 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751970AbXEaNlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2007 09:41:36 -0400
Content-Disposition: inline
In-Reply-To: <200705311354.56979.osstklei@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm still very unhappy with having all this in various drivers.  There's
a lot of code that can be turned into generic library functions, and even
more code that could be made generic with some amount of refactoring.
