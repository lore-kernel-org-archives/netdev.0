From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [PATCH] Fix crash on big-endian systems during scan
Date: Sun, 16 Apr 2006 18:06:02 -0700
Message-ID: <20060417010602.GL9551@jm.kir.nu>
References: <20060414215911.17273.40460.stgit@dv.roinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hostap@shmoo.com,
	Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.genealogia.fi ([194.100.116.229]:34793 "EHLO
	mail2.genealogia.fi") by vger.kernel.org with ESMTP
	id S1750885AbWDQBGS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Apr 2006 21:06:18 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
In-Reply-To: <20060414215911.17273.40460.stgit@dv.roinet.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 14, 2006 at 05:59:11PM -0400, Pavel Roskin wrote:

> The original code was doing arithmetics on a little-endian value.

John, please apply this to wireless-2.6 tree. This code is triggered at
least for the case where WPA is not used. I had noticed it before, but I
think I've only tested WPA/WPA2 on big endian systems..

-- 
Jouni Malinen                                            PGP id EFC895FA
