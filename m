From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] via-velocity: don't oops on MTU change.
Date: Fri, 16 Nov 2007 08:47:06 -0800
Message-ID: <20071116084706.467aa834@freepuppy.rosehill>
References: <20071114193844.0cab5c7d@freepuppy.rosehill>
	<20071115082600.GA2366@ff.dom.local>
	<20071115102005.0cf46f9a@freepuppy.rosehill>
	<473CD1F6.9030709@o2.pl>
	<cccedfc60711151842l4aafe0ffo220e84a5e37b6a82@mail.gmail.com>
	<20071115203508.4ad025f2@freepuppy.rosehill>
	<cccedfc60711160821p5f1790eaq8d385e71726cd5a0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Jarek Poplawski" <jarkao2@o2.pl>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	jnelson-kernel-bugzilla@jamponi.net
To: "Jon Nelson" <jnelson@jamponi.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39205 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753583AbXKPQs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2007 11:48:58 -0500
In-Reply-To: <cccedfc60711160821p5f1790eaq8d385e71726cd5a0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 16 Nov 2007 10:21:25 -0600
"Jon Nelson" <jnelson@jamponi.net> wrote:

> I get a segmentation fault.
> 
> Should this patch be in addition to the one from bug 9382?
> http://bugzilla.kernel.org/attachment.cgi?id=13555&action=view
> 
Yes. The new patch adds just recomputes the rx buf size in
one place, so it can be set when device is down.
Also, the computation will always yield same result now, the old
code computed different values depending on whether it was initial
or changed MTU.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
