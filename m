From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: using C99 in nasm
Date: Sun, 28 Jun 2009 22:19:15 +0400
Message-ID: <20090628181915.GB19425@lenovo>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NKML <netdev@vger.kernel.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:33776 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752990AbZF1STP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2009 14:19:15 -0400
Received: by fg-out-1718.google.com with SMTP id e12so326694fga.17
        for <netdev@vger.kernel.org>; Sun, 28 Jun 2009 11:19:18 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

is there a special reason why don't we
use C99 style of assignment for structure members?

For exmaple when assign ofmt structure members
why don't use positional independing fashion
like

struct ofmt of_macho = {
	.fullname	= "NeXTstep/OpenStep/Rhapsody/Darwin/MacOS X object files",
	.shortname	= "macho",
	.helpstring	= NULL,
	.debug_formats	= null_debug_arr,
	...
};

For the sake of portability maybe?

	-- Cyrill
