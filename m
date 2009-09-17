From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH 2/2] ipv4: make do_ip_setsockopt for IP_MULTICAST_IF support ip_mreq struct
Date: Thu, 17 Sep 2009 13:36:22 +0400
Message-ID: <20090917093622.GA19142@ms2.inr.ac.ru>
References: <1253164811-15820-1-git-send-email-dfeng@redhat.com> <4AB1FE6E.9000201@cn.fujitsu.com> <4AB1FF14.6000801@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shan Wei <shanwei@cn.fujitsu.com>, davem@davemloft.net,
	kaber@trash.net, yoshfuji@linux-ipv6.org, jmorris@namei.org,
	pekkas@netcore.fi, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Marc Milgram <mmilgram@redhat.com>
To: Danny Feng <dfeng@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:54194 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751778AbZIQK3Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2009 06:29:25 -0400
Content-Disposition: inline
In-Reply-To: <4AB1FF14.6000801@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On Thu, Sep 17, 2009 at 05:19:16PM +0800, Danny Feng wrote:
> In fact, current implemetation supports:
> 
> struct ip_mreqn mreqn;
> setsockopt(socket, IPPROTO_IP, IP_MULTICAST_IF, &mreqn, sizeof(mreqn));
> 
> Then why not support mreq?

Because support of ip_mreqn makes sense (it user interface index)
and support of ip_mreq, which does not contain interface index,
does not. "Polymorphic" IP_MULTICAST_IF was a stupid mistake (mine),
which should not grow like a tumor.

Ack to patch #1, nack to #2.

Alexey

