From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 3/4] ehea: queue managment
Date: Wed, 7 Jun 2006 10:29:50 -0700
Message-ID: <20060607102950.54dd83c1@localhost.localdomain>
References: <4487073E.1020403@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, meder@de.ibm.com, raisch@de.ibm.com,
	themann@de.ibm.com, tklein@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:14223 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932360AbWFGRaC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2006 13:30:02 -0400
To: Jan-Bernd Themann <ossthema@de.ibm.com>
In-Reply-To: <4487073E.1020403@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 07 Jun 2006 19:05:02 +0200
Jan-Bernd Themann <ossthema@de.ibm.com> wrote:

> Signed-off-by:  Jan-Bernd Themann <themann@de.ibm.com>
> 
> 
> drivers/net/ehea/ehea_qmr.c |  719 ++++++++++++++++++++++++++++++++++++++++++++
> drivers/net/ehea/ehea_qmr.h |  390 +++++++++++++++++++++++
> 2 files changed, 1109 insertions(+)
> 

Make it look less like C++

Do you really need to use vmalloc/vfree? Are the data structures that big?

Be careful about global namespace issues. Stick to one prefix like ehea_
for all non static function names. Consider putting all in one file, or
use #include to cause it to be one compilation unit.


