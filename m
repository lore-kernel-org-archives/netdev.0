From: Don Fry <pcnet32@verizon.net>
Subject: Re: [PATCH] pcnet32: fix non-napi packet reception
Date: Wed, 17 Oct 2007 17:04:01 -0700
Message-ID: <1192665841.13749.4.camel@Linux.home>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms042pub.verizon.net ([206.46.252.42]:41775 "EHLO
	vms042pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759318AbXJRAKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 20:10:42 -0400
Received: from [192.168.1.2] ([71.117.241.192])
 by vms042.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0JQ2002RRZ5R2OW2@vms042.mailsrvcs.net> for
 netdev@vger.kernel.org; Wed, 17 Oct 2007 19:10:41 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>In general, we're hoping to remove as many CONFIG_FOO_NAPI as possible,
>pushing everybody towards using NAPI.
>
>Any objection to heading in this direction with pcnet32?
>
>        Jeff

I have no objections myself.  It has been slowly moving that direction.
First with the napi implementation, default off, labeled experimental.
Then removing experimental and then making the default on.

If any other user of the pcnet32 has objections, now is the time to
speak loudly!

Don

