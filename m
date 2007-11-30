From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 4/4] net: Implement the per network namespace sysctl	infrastructure
Date: Fri, 30 Nov 2007 19:23:15 +0300
Message-ID: <475038F3.9010209@openvz.org>
References: <4742C73C.3010904@openvz.org> <m1odddc5mf.fsf@ebiederm.dsl.xmission.com> <m1k5o1c5eh.fsf_-_@ebiederm.dsl.xmission.com> <m1fxypc5cd.fsf_-_@ebiederm.dsl.xmission.com> <m1bq9dc53d.fsf_-_@ebiederm.dsl.xmission.com> <m17ik1c50m.fsf_-_@ebiederm.dsl.xmission.com> <20071130161856.GA10588@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Cedric Le Goater <clg@fr.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:58276 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761232AbXK3Q1O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 11:27:14 -0500
In-Reply-To: <20071130161856.GA10588@sergelap.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[snip]

>> +					&namespaces, path, table);
> 
> Hey Eric,
> 
> the patches look nice.

Agree ;)

> The hand-forcing of the passed-in net_ns into a copy of current->nsproxy
> does make it seem like nsproxy may not be the best choice of what to
> pass in.  Doesn't only net_sysctl_root->lookup() look at the argument?
> 
> But I assume you don't want to be more general than sending in a
> nsproxy so as to dissuade abuse of this interface for needlessly complex
> sysctl interfaces?
> 
> (Well I expect that'll become clear once the the patches using this
> come out.)
> 
> Are you planning to use this infrastructure for the uts and ipc
> sysctls as well?

I have sent some patches concerning uts and ipc already.
I'd appreciate any feedback on it :)

> thanks,
> -serge

Thanks,
Pavel
