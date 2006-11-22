From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [patch -mm] net namespace: empty framework
Date: Wed, 22 Nov 2006 10:41:54 -0600
Message-ID: <20061122164154.GB17378@sergelap.austin.ibm.com>
References: <4563007B.9010202@fr.ibm.com> <4563046B.6040909@sw.ru> <45633EDF.3050309@fr.ibm.com> <200611221121.59322.dim@openvz.org> <4564566F.7030202@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Mishin <dim@openvz.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Kirill Korotaev <dev@sw.ru>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Herbert Poetzl <herbert@13thfloor.at>,
	"Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:29365 "EHLO e2.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1755381AbWKVQl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Nov 2006 11:41:57 -0500
To: Cedric Le Goater <clg@fr.ibm.com>
Content-Disposition: inline
In-Reply-To: <4564566F.7030202@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Cedric Le Goater (clg@fr.ibm.com):
> Hello,
> 
> Dmitry Mishin wrote:
> 
> > This patch looks acceptable for us.
> 
> good. shall we merge it then ? see comment below.
> 
> > BTW, Daniel, we agreed to be based on the Andrey's patchset. I do not see a
> > reason, why Cedric force us to make some unnecessary work and move existent
> > patchset over his interface.
> 
> yeah it's a bit different from andrey's but not that much and it's more in

Where is Andrey's patch?

> the spirit of uts and ipc namespace (and user namespace if that reaches the
> kernel one day :) so that's why i made the small changes.

I agree the namespace frameworks should be consistent, but i don't know
whether Andrey's is or not.  I'd like to have the framework included so
we reduce the number of silly rewrites due to clone flag collisions etc.

> 
> It also helping the nsproxy/namespace syscalls to have a similar interface
> to manipulate namespaces. who knows, soon we might be able to have a 'struct
> namespace' with a ops field to define new namespace types ?
> 
> I can also send a empty framework for user namespace  ;)

Please do - then I'll rebase the patchset I sent to the containes list
onto your patch, and resubmit the whole userns.

-serge
