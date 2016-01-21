From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH v3 00/16] add Intel X722 iWARP driver
Date: Thu, 21 Jan 2016 20:40:53 +0200
Message-ID: <CAJ3xEMgE1-EuNBmYVfLoBwjohcxt5tio6wtZn=TYvDAgQgh9cw@mail.gmail.com>
References: <1453318816-21672-1-git-send-email-faisal.latif@intel.com>
	<CAJ3xEMhxMzAVJUNbBHrG8hia2tcFJ4cuPHpq3t9p0FqPHfYX+Q@mail.gmail.com>
	<00cf01d153d5$e6248eb0$b26dac10$@opengridcomputing.com>
	<56A08E8F.7090602@mellanox.com>
	<004401d15460$e77fa1b0$b67ee510$@opengridcomputing.com>
	<56A10FEC.5020402@mellanox.com>
	<20160121182420.GA51708@flatif-MOBL1>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Steve Wise <swise@opengridcomputing.com>,
	Doug Ledford <dledford@redhat.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-rdma@lists.sourceforge.net
To: Faisal Latif <faisal.latif@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f194.google.com ([209.85.213.194]:33817 "EHLO
	mail-ig0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759632AbcAUSkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 13:40:55 -0500
In-Reply-To: <20160121182420.GA51708@flatif-MOBL1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 21, 2016 at 8:24 PM, Faisal Latif <faisal.latif@intel.com> wrote:

> We can certainly take up the discussion on improving the current port mapper design/implementation. But
> that would be more appropriate in a separate thread.

If we observe a kernel API / mechanism which could be wrongly
duplicated between two drivers, and now a new driver comes to town
with C&P-ing this -- why not stopping and thinking before rushing to
get the 3rd duplication upstream?
