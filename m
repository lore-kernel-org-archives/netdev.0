From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Enable netem in my Linux box
Date: Thu, 10 May 2007 11:23:02 -0700
Message-ID: <20070510112302.770237f1@freepuppy>
References: <4641E945.3070902@lucent.com>
	<20070510084232.147e1d8f@freepuppy>
	<464343CA.6090500@lucent.com>
	<20070510095738.563a23bf@localhost>
	<46435DC8.6000807@lucent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Koon Wah Yick <kyick@alcatel-lucent.com>, netdev@vger.kernel.org,
	"Yick, Koon Wah (Koon)" <kyick@homail.ho.lucent.com>
To: Koon Wah Yick <kyick@alcatel-lucent.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:38233 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756396AbXEJSXM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 14:23:12 -0400
In-Reply-To: <46435DC8.6000807@lucent.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 10 May 2007 14:00:40 -0400
Koon Wah Yick <kyick@alcatel-lucent.com> wrote:

> Stephen:
> 
> Thank you, I got it.  I try the same command again with "add" and "change" they
> all work.(no error)  But when I start my Network Emulator, how can I stop it.
> Do I have to delete any file I create when doing "add"?  If yes, where is it?

You probably just want to do: 
tc qdisc del dev eth0 root

That restores the default qdisc (prio-fast)

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
