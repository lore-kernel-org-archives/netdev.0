From: Josh Boyer <jwboyer@redhat.com>
Subject: loopback IP alias breaks tftp?
Date: Wed, 5 Oct 2011 16:27:23 -0400
Message-ID: <20111005202723.GE2479@zod.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3684 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932349Ab1JEU10 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Oct 2011 16:27:26 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p95KRQqP030401
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 5 Oct 2011 16:27:26 -0400
Received: from zod.bos.redhat.com (ovpn-113-43.phx2.redhat.com [10.3.113.43])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p95KRNG7010383
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 5 Oct 2011 16:27:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

We've had a report [1] of a change in behavior when trying to use an IP
alias to tftp from a loopback device.  Apparently the steps outlined in
the bug worked in 2.6.35, and broke somewhere before 2.6.38.6.

I can confirm the steps fail on a 3.0 based kernel and I'm trying to do
a git bisect to find the commit involved, but I thought I would send
this along to see if anyone might have an idea.  (Also, I'm not really
sure how valid of a usecase this was to begin with.)

[1] https://bugzilla.redhat.com/show_bug.cgi?id=739534

josh
