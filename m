From: Cong Wang <amwang@redhat.com>
Subject: Re: A soft lockup in vxlan module
Date: Wed, 07 Aug 2013 10:34:44 +0800
Message-ID: <1375842884.11370.23.camel@cr0>
References: <1375838634.11370.13.camel@cr0>
	 <CAOaVG14-vSR-gt+c8zMe+rk6MX4xO3dGxZHi--M6Nun+qTOSVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58118 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756830Ab3HGCew (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 22:34:52 -0400
In-Reply-To: <CAOaVG14-vSR-gt+c8zMe+rk6MX4xO3dGxZHi--M6Nun+qTOSVQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-06 at 19:18 -0700, Stephen Hemminger wrote:
> Calling unlock in dellink is not safe.

This is my feeling as well.

> can you reproduce with 3.10 or 3.11-rc?
> 

For net-next, I always compile modules as builtin, therefore can't test
it. But clearly the code is same.

The steps to reproduce it are:

1) ping over vxlan0
2) modprobe -r vxlan
