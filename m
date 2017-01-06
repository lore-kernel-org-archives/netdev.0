From: Roger Pau =?iso-8859-1?Q?Monn=E9?= <roger.pau@citrix.com>
Subject: Re: [PATCH 2/3] xen: modify xenstore watch event interface
Date: Fri, 6 Jan 2017 16:37:13 +0000
Message-ID: <20170106163713.tisdy6cj7muwu3h3@dhcp-3-221.uk.xensource.com>
References: <20170106150544.10836-1-jgross@suse.com>
 <20170106150544.10836-3-jgross@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: <linux-kernel@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
        <boris.ostrovsky@oracle.com>, <konrad.wilk@oracle.com>,
        <wei.liu2@citrix.com>, <paul.durrant@citrix.com>,
        <netdev@vger.kernel.org>
To: Juergen Gross <jgross@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:63907 "EHLO
        SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751017AbdAFQhT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 11:37:19 -0500
Content-Disposition: inline
In-Reply-To: <20170106150544.10836-3-jgross@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 06, 2017 at 04:05:43PM +0100, Juergen Gross wrote:
> Today a Xenstore watch event is delivered via a callback function
> declared as:
> 
> void (*callback)(struct xenbus_watch *,
>                  const char **vec, unsigned int len);
> 
> As all watch events only ever come with two parameters (path and token)
> changing the prototype to:
> 
> void (*callback)(struct xenbus_watch *,
>                  const char *path, const char *token);
> 
> is the natural thing to do.
> 
> Apply this change and adapt all users.
> 
> Cc: konrad.wilk@oracle.com
> Cc: roger.pau@citrix.com
> Cc: wei.liu2@citrix.com
> Cc: paul.durrant@citrix.com
> Cc: netdev@vger.kernel.org
> 
> Signed-off-by: Juergen Gross <jgross@suse.com>

blkback changes:

Reviewed-by: Roger Pau Monné <roger.pau@citrix.com>

Thanks, Roger.
