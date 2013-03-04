From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 2/8] netback: add module unload function
Date: Mon, 4 Mar 2013 13:58:31 -0800
Message-ID: <20130304135831.4d52eddc@nehalam.linuxnetplumber.net>
References: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
	<1360944010-15336-3-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<ian.campbell@citrix.com>, <konrad.wilk@oracle.com>,
	<annie.li@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:49747 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932305Ab3CDV6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 16:58:37 -0500
Received: by mail-pb0-f46.google.com with SMTP id uo15so3459759pbc.5
        for <netdev@vger.kernel.org>; Mon, 04 Mar 2013 13:58:36 -0800 (PST)
In-Reply-To: <1360944010-15336-3-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Feb 2013 16:00:03 +0000
Wei Liu <wei.liu2@citrix.com> wrote:

> Enable users to unload netback module. Users should make sure there is not vif
> runnig.


Isn't it likely that some admin might be trying to cleanup or do shutdown and there
is an ordering problem. What happens if vif's are still running?

Why depend on users? You should allow it anytime and do refcounting and auto-destroy the vif's for them.
