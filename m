From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Subject: Re: [PATCH] dccp: remove module exit functions
Date: Fri, 10 Nov 2006 11:55:08 -0200
Message-ID: <39e6f6c70611100555u6e2a4e0fq8dba12557f40139b@mail.gmail.com>
References: <XMMS.LNX.4.64.0611100345300.10983@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "dccp (vger)" <dccp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.227]:25192 "EHLO
	wx-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1946033AbWKJNzJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 08:55:09 -0500
Received: by wx-out-0506.google.com with SMTP id s7so71735wxc
        for <netdev@vger.kernel.org>; Fri, 10 Nov 2006 05:55:09 -0800 (PST)
To: "James Morris" <jmorris@namei.org>
In-Reply-To: <XMMS.LNX.4.64.0611100345300.10983@d.namei>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/10/06, James Morris <jmorris@namei.org> wrote:
> The dccp ipv4 & ipv6 modules cannot be unloaded, as their control sockets
> each maintain a couple of module references.  So, it seems like a good
> idea to just remove the module exit functions completely.
>
> Please review.

Well, I have a patch in the DCCP backlog that uses it, ressurecting
the unload hack, for development purposes being able to destroy the
control sockets allowing module removal is something the DCCP
developers want :)

- Arnaldo
