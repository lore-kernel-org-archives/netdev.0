From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 00/12] add namespace support for netfilter protos
Date: Tue, 17 Apr 2012 12:34:48 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1204171233590.31683@frira.zrqbmnf.qr>
References: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, ebiederm@xmission.com,
	serge.hallyn@canonical.com, dlezcano@fr.ibm.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from seven.medozas.de ([188.40.89.202]:60429 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751153Ab2DQKew (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2012 06:34:52 -0400
In-Reply-To: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tuesday 2012-04-17 04:56, Gao feng wrote:

>Currently the sysctl of netfilter proto is not isolated, so when 
>changing proto's sysctl in container will cause the host's sysctl 
>be changed too. it's not expected.

I wonder if it made sense to do the configuration of NFCT via
netlink as well, and deprecate the sysctl interface.
