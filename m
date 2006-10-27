From: Christoph Raisch <RAISCH@de.ibm.com>
Subject: Re: [PATCH 2.6.19-rc3 1/2] ehea: kzalloc GFP_ATOMIC fix
Date: Fri, 27 Oct 2006 13:17:51 +0200
Message-ID: <OF9B06F6DE.7191F185-ONC1257214.003DB403-C1257214.003DD10C@de.ibm.com>
References: <20061026201313.9c831fc9.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Jan-Bernd Themann <themann@de.ibm.com>,
	Jeff Garzik <jeff@garzik.org>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>, ossthema@de.ibm.com,
	Thomas Q Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:54569 "EHLO
	mtagate3.de.ibm.com") by vger.kernel.org with ESMTP
	id S1946401AbWJ0LPS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Oct 2006 07:15:18 -0400
In-Reply-To: <20061026201313.9c831fc9.akpm@osdl.org>
To: Andrew Morton <akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Andrew Morton <akpm@osdl.org> wrote on 27.10.2006 05:13:13:

> On Wed, 25 Oct 2006 13:11:42 +0200
> Jan-Bernd Themann <ossthema@de.ibm.com> wrote:
>
> > This patch fixes kzalloc parameters (GFP_ATOMIC instead of GFP_KERNEL)
>
> why?


these few kcallocs run in atomic context in some situations.
therefore GFP_KERNEL is no good idea.

Christoph R.

