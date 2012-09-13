From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] Xen backend support for paged out grant targets.
Date: Thu, 13 Sep 2012 19:11:39 +0100
Message-ID: <1347559899.25803.64.camel@dagon.hellion.org.uk>
References: <1347557306-25453-1-git-send-email-andres@lagarcavilla.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@xen.lists.org" <xen-devel@xen.lists.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	David Miller <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andres Lagar-Cavilla <andres@lagarcavilla.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:28482 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758709Ab2IMSLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 14:11:41 -0400
In-Reply-To: <1347557306-25453-1-git-send-email-andres@lagarcavilla.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-13 at 18:28 +0100, Andres Lagar-Cavilla wrote:
> 
> * Add placeholder in array of grant table error descriptions for
> unrelated error code we jump over. 

Why not just define it, it's listed here:
http://xenbits.xen.org/docs/unstable/hypercall/include,public,grant_table.h.html#Enum_grant_status

I notice the specific wording of the error msg is different here too.
It'd probably be best to use the same wording as the Xen definition, so
all OSes end up with the same name for the same condition (else bug
reports will be confusing).

Ian.
