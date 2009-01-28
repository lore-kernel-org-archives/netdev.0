From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 20/21] RDS: Kconfig and Makefile
Date: Wed, 28 Jan 2009 14:59:45 -0800
Message-ID: <adazlhbt4ta.fsf@cisco.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
	<1233022678-9259-21-git-send-email-andy.grover@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rds-devel@oss.oracle.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: Andy Grover <andy.grover@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:11152 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240AbZA1W7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 17:59:47 -0500
In-Reply-To: <1233022678-9259-21-git-send-email-andy.grover@oracle.com> (Andy
	Grover's message of "Mon, 26 Jan 2009 18:17:57 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > +obj-$(CONFIG_INFINIBAND_ISER)		+= ulp/rds/

Typo for ..._RDS

 > +config INFINIBAND_RDS_DEBUG
 > +        bool "Debugging messages"
 > +	depends on INFINIBAND_RDS
 > +        default n

No way to enable this?  Disabled by default?

You really want debugging messages to be built by default and controlled
at runtime ... otherwise debugging end-user installations is a pain
(they just install what the distro gives them, and it's very hard for
them to rebuild just to enable debugging).

 > +ib_rds-y :=	af_rds.o bind.o cong.o connection.o info.o message.o   \
 > +			recv.o send.o stats.o sysctl.o threads.o transport.o \
 > +			loop.o page.o rdma.o
 > +
 > +ib_rds-y += ib.o ib_cm.o ib_recv.o ib_ring.o ib_send.o ib_stats.o \
 > +			ib_sysctl.o ib_rdma.o

a very strange way to write an assignment statement...

 - R.
