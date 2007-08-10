From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.23-rc2-mm2
Date: Fri, 10 Aug 2007 01:32:10 -0700
Message-ID: <20070810013210.1b2f121c.akpm@linux-foundation.org>
References: <20070809224254.11f42716.akpm@linux-foundation.org>
	<a8e1da0708100118r779068i64ffdc11e452be9b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Dave Young" <hidave.darkstar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56407 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752761AbXHJIcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 04:32:51 -0400
In-Reply-To: <a8e1da0708100118r779068i64ffdc11e452be9b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 10 Aug 2007 16:18:38 +0800 "Dave Young" <hidave.darkstar@gmail.com> wrote:

> Hi,
> 2.6.23-rc2-mm2:
> config with CONFIG_NF_CONNTRACK_AMANDA=y
> boot  oops:
> 
> hand copyed :
> the EIP: helper_hash
> 
> backtrace:
> do_basic_setup
> ...
> nf_conntrack_amanda_init
> error_code
> do_vivide_error
> ...
> 

cc netdev

please send config

presumably nf_ct_helper_hsize is zero

I'd have thought that the same bug would be present in mainline - there's
nothing in git-net.patch.

(hunts around, discovers that there's a net-2.6.24 tree now.  Bah)
