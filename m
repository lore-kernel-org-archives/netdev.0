From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH 00/13] drivers: hv: kvp
Date: Tue, 03 Jul 2012 08:03:09 -0700 (PDT)
Message-ID: <642e6af6-fc6b-4c54-a4a6-f5bdd38512c7@tahiti.vyatta.com>
References: <20120703132049.GA10663@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@linuxfoundation.org>, apw@canonical.com,
	devel@linuxdriverproject.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, KY Srinivasan <kys@microsoft.com>
To: Olaf Hering <olaf@aepfle.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120703132049.GA10663@aepfle.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On Mon, Jul 02, KY Srinivasan wrote:
> 
> > While I toyed with your proposal, I feel it just pushes the problem
> > out of the daemon code - we would still need to write distro
> > specific
> > scripts. If this approach is something that everybody is
> > comfortable
> > with, I can take a stab at implementing that.
> 
> Until NetworkManager is feature complete and until every distro is
> using
> NetworkManager per default the kvp_daemon needs distro specific code
> to
> get and set network related settings.
> Doing it with an external script will simplify debugging and changes
> to
> the code.

Although,  Network Manager is a good tool for what it does;
it is not appropriate for every distro. It is overkill
in embedded systems, and it's GUI dependency makes it unmanageable
on servers. 
