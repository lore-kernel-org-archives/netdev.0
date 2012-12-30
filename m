From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next] team: add ethtool support
Date: Sat, 29 Dec 2012 17:29:45 -0800
Message-ID: <20121229172945.25a09fc8@nehalam.linuxnetplumber.net>
References: <1356830366-991-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45234 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753705Ab2L3BbJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Dec 2012 20:31:09 -0500
In-Reply-To: <1356830366-991-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 29 Dec 2012 23:19:26 -0200
Flavio Leitner <fbl@redhat.com> wrote:

> This patch adds few ethtool operations to team driver.
> 
> Signed-off-by: Flavio Leitner <fbl@redhat.com>

What is the motivation for this? Is there an application that depends
on ethtool (versus netlink, or /proc)?

Sorry, I see no point in providing ethtool statistics for generic data that is already
reported by existing netlink and other infrastructure. The purpose of ethtool
statistics is to report device specific that is not available through the normal
generic statistics.
