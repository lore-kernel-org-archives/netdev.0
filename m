From: Loganaden Velvindron <logan@elandsys.com>
Subject: Re: [PATCH net-next] net: bridge: use vzalloc() instead of vmalloc()
 as counterstmp is not cleared before it is used in get_counters().
 counterstmp might be leaked partially when it is sent to userland later on.
Date: Wed, 28 Oct 2015 11:35:20 -0700
Message-ID: <20151028183520.GB19990@mx.elandsys.com>
References: <20151028155654.GA2775@mx.elandsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.qubic.net ([208.69.177.116]:62554 "EHLO mx.elandsys.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751237AbbJ1SfW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Oct 2015 14:35:22 -0400
Received: from mx.elandsys.com (IDENT:logan@localhost [127.0.0.1])
	by mx.elandsys.com (8.14.5/8.14.5) with ESMTP id t9SIZKG0026994
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 11:35:20 -0700 (PDT)
Received: (from logan@localhost)
	by mx.elandsys.com (8.14.5/8.14.5/Submit) id t9SIZKi4004587
	for netdev@vger.kernel.org; Wed, 28 Oct 2015 11:35:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20151028155654.GA2775@mx.elandsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please reject this patch. I sent a proper one with the sign-on later on.
