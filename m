From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [2.6 patch] always export sysctl_{r,w}mem_max
Date: Fri, 26 Oct 2007 16:46:36 -0700
Message-ID: <47227C5C.1070507@hp.com>
References: <20071026230807.GE30533@stusta.de>	<m1zly5wjie.fsf@ebiederm.dsl.xmission.com>	<472278E3.4000909@hp.com> <20071026.163958.171785530.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, bunk@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:33239 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759694AbXJZXqj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2007 19:46:39 -0400
In-Reply-To: <20071026.163958.171785530.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> If DLM really wants minimum, it can use SO_SNDBUFFORCE and
> SO_RCVBUFFORCE socket options and use whatever limits it
> likes.
> 
> But even this is questionable.

Drift...

Is that something netperf should be using though?  Right now it uses the regular 
SO_[SND|RCV]BUF calls and is at the mercy of sysctls.  I wonder if it would be 
better to have it use their FORCE versions to make life easier on the 
benchmarker - such as myself - who has an unfortunate habit of forgetting to 
update sysctl.conf :)

rick jones
