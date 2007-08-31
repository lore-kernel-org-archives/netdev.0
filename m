From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: wither bounds checking for networking sysctls
Date: Thu, 30 Aug 2007 20:59:39 -0700
Message-ID: <20070830205939.2f85a567@localhost>
References: <46D76A3D.9090207@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46708 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752282AbXHaD7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2007 23:59:47 -0400
In-Reply-To: <46D76A3D.9090207@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 30 Aug 2007 18:09:17 -0700
Rick Jones <rick.jones2@hp.com> wrote:

> While messing about with "sysctl_tcp_rto_min" I went back and forth a 
> bit as to whether there should have been bounds checking (as did some of 
> the folks who did some internal review for me).  That leads to the 
> question - is it considered worthwhile to add a bit more bounds checking 
> to sundry networking sysctls?
> 
> rick jones

IMHO As long as the any value from sysctl doesn't crash kernel, we
should let it go. Enforcing RFC policy or inter-dependencies seems
likes a useless exercise.
