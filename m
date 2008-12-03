From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH 02/39] wimax: declarations for the in-kernel WiMAX API
Date: Tue, 2 Dec 2008 18:07:31 -0800
Message-ID: <200812021807.31959.inaky@linux.intel.com>
References: <cover.1227691434.git.inaky@linux.intel.com> <68881c1af06f352dc457485c208662a8db62f3fe.1227691434.git.inaky@linux.intel.com> <1227778323.3809.19.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:39507 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752812AbYLCCL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 21:11:29 -0500
In-Reply-To: <1227778323.3809.19.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 27 November 2008, Johannes Berg wrote:
> Why bother versioning the API? Since this is generic netlink, and things
> are looked up by the family name, a completely new version would just
> use a new family name and be done with it, old userspace won't even
> _find_ that new "version" of the API.

That'd be a way to do majors -- hadn't thought about it.

But then, it forces a way to create "a way to grok versions" in the
family name, which is moving the problem from one place to the other.

Because parsing in the family means having to set a protocol and
parsing ASCII, I'd say it's easier to use the family's version field,
as it is available.

> The "minor version" seems also
> useless, either you can do the change in a backward compatible way or
> you cannot and need to provide compat code.

No it is not -- you are missing the case of adding an API
call/signal. Addition doesn't break backwards compatibility, yet a
user that requires the addition has to double check it is
available.

-- 
Inaky

