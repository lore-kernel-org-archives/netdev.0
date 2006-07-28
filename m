From: Zach Brown <zach.brown@oracle.com>
Subject: Re: [RFC 1/4] kevent: core files.
Date: Fri, 28 Jul 2006 12:01:28 -0700
Message-ID: <44CA5F08.3080500@oracle.com>
References: <20060709132446.GB29435@2ka.mipt.ru> <20060724.231708.01289489.davem@davemloft.net> <44C91192.4090303@oracle.com> <20060727205806.GD16971@kvack.org> <44C933D2.4040406@oracle.com> <20060727220238.GE16971@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tetsuo.zabbo.net ([207.173.201.20]:5099 "EHLO tetsuo.zabbo.net")
	by vger.kernel.org with ESMTP id S1161239AbWG1TB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 15:01:29 -0400
To: Benjamin LaHaise <bcrl@kvack.org>
In-Reply-To: <20060727220238.GE16971@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Things were like that at one point in time, but file descriptors turn out 
> to introduce a huge gaping security hole with SUID programs.  The problem 
> is that any event context is closely tied to the address space of the 
> thread issuing the syscalls, and file descriptors do not have this close 
> binding.

Can you go into that hole in more detail?

> Except that you're not usually pulling a full ring worth of events at a 
> time, more often just one.

OK, but then to wait for it you were already sleeping in the kernel, right?

Clearly we should port httpd to kevents and take some measurements :)

- z
