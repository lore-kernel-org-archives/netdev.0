From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH wireless-dev] d80211: Add support for user space client
 MLME
Date: Wed, 3 May 2006 18:28:15 +0200
Message-ID: <20060503182815.1a9ebb5e@griffin.suse.cz>
References: <20060502211817.GA30842@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:21941 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1030237AbWECQ2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 May 2006 12:28:17 -0400
To: "Jouni Malinen" <jkm@devicescape.com>
In-Reply-To: <20060502211817.GA30842@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2 May 2006 14:18:17 -0700, Jouni Malinen wrote:
> Add a configuration option for disabling client MLME in kernel
> code. This is used to enable user space MLME for client mode (e.g.,
> with wpa_supplicant). The kernel MLME implementation is unmodified,
> but it could be removed or at least made optional in build
> configuration in the future.

It is too early for this. We need to implement some better communication
interface between kernel and hostapd (or what will implement userspace
MLME) first. The current solution, where there is some special
net_device interface (wmaster0ap) abused to dump informations to
userspace, is ugly and confusing for users.

There is no userspace MLME implementation yet. And if one is going to be
written, I'm really convinced it should be written in a clean way. I
think Simon said he would examine a possibility to convert this stuff to
netlink - is there some progress there?

Also, I'm not sure how fullmac cards could be (potentially) supported
with this approach.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
