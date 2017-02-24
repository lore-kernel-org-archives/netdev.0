From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute2: tc: introduce build dependency on libnetlink
Date: Fri, 24 Feb 2017 15:13:03 -0800
Message-ID: <20170224151303.249584ec@xeon-e3>
References: <alpine.LSU.2.20.1702241826540.24579@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jiri Kosina <jikos@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34158 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751291AbdBXXNM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 18:13:12 -0500
Received: by mail-pf0-f169.google.com with SMTP id p185so3065675pfb.1
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2017 15:13:12 -0800 (PST)
In-Reply-To: <alpine.LSU.2.20.1702241826540.24579@cbobk.fhfr.pm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 24 Feb 2017 18:28:54 +0100 (CET)
Jiri Kosina <jikos@kernel.org> wrote:

> From: Jiri Kosina <jkosina@suse.cz>
> 
> Rebuilding libnetlink doesn't trigger rebuild of tc, which is wrong 
> (especially so for builds where libnetlink.a gets statically linked into 
> tc). Fix that by introducing an explicit dependency.
> 
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>

Makes sense, Applied
