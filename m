From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [patch -mm] net namespace: empty framework
Date: Wed, 22 Nov 2006 20:39:44 -0600
Message-ID: <20061123023943.GA22931@sergelap.austin.ibm.com>
References: <4563007B.9010202@fr.ibm.com> <4564566F.7030202@fr.ibm.com> <20061122164154.GB17378@sergelap.austin.ibm.com> <200611221955.56942.dim@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
	Cedric Le Goater <clg@fr.ibm.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Kirill Korotaev <dev@sw.ru>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Herbert Poetzl <herbert@13thfloor.at>,
	"Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:38041 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1757267AbWKWCkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Nov 2006 21:40:49 -0500
To: Dmitry Mishin <dim@openvz.org>
Content-Disposition: inline
In-Reply-To: <200611221955.56942.dim@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Dmitry Mishin (dim@openvz.org):
> On Wednesday 22 November 2006 19:41, Serge E. Hallyn wrote:
> > Quoting Cedric Le Goater (clg@fr.ibm.com):
> > > Hello,
> > >
> > > Dmitry Mishin wrote:
> > >
> > > > This patch looks acceptable for us.
> > >
> > > good. shall we merge it then ? see comment below.
> > >
> > > > BTW, Daniel, we agreed to be based on the Andrey's patchset. I do not see a
> > > > reason, why Cedric force us to make some unnecessary work and move existent
> > > > patchset over his interface.
> > >
> > > yeah it's a bit different from andrey's but not that much and it's more in
> >
> > Where is Andrey's patch?
> This thread - http://thread.gmane.org/gmane.linux.network/42666

Thanks, Dmitry.  Now I do recall seeing that before.

That patchset appears to go part, but not all the way to fitting in with
the existing namespaces.  For instance, you use exit_task_namespaces() for
refcounting, but don't put the net_namespace in the nsproxy and use your
own mechanism for unsharing.

It really seems useful to have all the namespaces be consistent whenever
practical, and I don't think your patchset would need much tweaking to
fit onto Cedric's patch.  Am I missing a complicating factor?

thanks,
-serge
