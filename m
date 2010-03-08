From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 2/6] C/R: Basic support for network namespaces and devices (v5)
Date: Mon, 08 Mar 2010 10:07:47 -0800
Message-ID: <87tysqheks.fsf@caffeine.danplanet.com>
References: <1267130595-23637-1-git-send-email-danms@us.ibm.com>
	<1267130595-23637-3-git-send-email-danms@us.ibm.com>
	<4B91D1A3.9030404@cs.columbia.edu>
	<87bpf1idic.fsf@caffeine.danplanet.com>
	<4B92D574.1090006@cs.columbia.edu>
	<871vfuiul6.fsf@caffeine.danplanet.com>
	<m1hboqu2cv.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oren Laadan <orenl@cs.columbia.edu>, containers@lists.osdl.org,
	den@openvz.org, netdev@vger.kernel.org, davem@davemloft.net,
	benjamin.thery@bull.net
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:40821 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752241Ab0CHSHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 13:07:50 -0500
In-Reply-To: <m1hboqu2cv.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Mon\, 08 Mar 2010 09\:53\:20 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

EB> Can we take advantage of the fact that when you destroy a network
EB> namespace the virtual devices in that network namespace are also
EB> destroyed?

Hmm, that kinda seems like cheating, but maybe so.  I'll take a look :)

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
